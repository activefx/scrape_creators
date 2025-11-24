# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Pinterest do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:pinterest) { client.pinterest }

  describe "#search" do
    it "searches Pinterest pins successfully" do
      VCR.use_cassette("pinterest/search_success") do
        result = pinterest.search("italian recipes")

        assert_kind_of Hash, result
        assert result.key?(:success)
        assert result.key?(:pins)
        assert_kind_of Array, result[:pins]
        refute_empty result[:pins]
      end
    end

    it "returns pins with expected fields" do
      VCR.use_cassette("pinterest/search_success") do
        result = pinterest.search("italian recipes")

        pin = result[:pins].first

        assert pin.key?(:id)
        assert pin.key?(:url)
        assert pin.key?(:description)
        assert pin.key?(:images)
        assert pin.key?(:created_at)
      end
    end

    it "returns pin images with expected structure" do
      VCR.use_cassette("pinterest/search_success") do
        result = pinterest.search("italian recipes")

        pin = result[:pins].first

        assert pin.key?(:images)
        images = pin[:images]

        assert_kind_of Hash, images

        # Check for orig image
        if images[:orig]
          assert images[:orig].key?(:url)
          assert images[:orig].key?(:width)
          assert images[:orig].key?(:height)
        end
      end
    end

    it "returns board information" do
      VCR.use_cassette("pinterest/search_success") do
        result = pinterest.search("italian recipes")

        pin = result[:pins].first

        if pin[:board]
          board = pin[:board]

          assert board.key?(:name)
          assert board.key?(:url)
        end
      end
    end

    it "returns pinner information" do
      VCR.use_cassette("pinterest/search_success") do
        result = pinterest.search("italian recipes")

        pin = result[:pins].first

        if pin[:pinner]
          pinner = pin[:pinner]

          assert pinner.key?(:username)
          assert pinner.key?(:full_name)
        end
      end
    end

    it "includes pagination cursor in response" do
      VCR.use_cassette("pinterest/search_success") do
        result = pinterest.search("italian recipes")

        assert result.key?(:cursor)
      end
    end

    it "searches with cursor parameter" do
      VCR.use_cassette("pinterest/search_with_cursor") do
        result = pinterest.search("home decor", cursor: "Y2JVSG81V2")

        assert_kind_of Hash, result
        assert result.key?(:success)
        # End of pagination may not include pins array
        assert_kind_of Array, result[:pins] if result.key?(:pins)
      end
    end

    it "searches with trim parameter" do
      VCR.use_cassette("pinterest/search_trimmed") do
        result = pinterest.search("fashion", trim: true)

        assert_kind_of Hash, result
        assert result.key?(:pins)
      end
    end

    it "searches with all parameters" do
      VCR.use_cassette("pinterest/search_all_params") do
        result = pinterest.search(
          "photography",
          cursor: "Y2JVSG81V2",
          trim: true
        )

        assert_kind_of Hash, result
        assert result.key?(:success)
        # End of pagination may not include pins array
        assert_kind_of Array, result[:pins] if result.key?(:pins)
      end
    end

    describe "argument validation" do
      it "raises ArgumentError when query is nil" do
        error = assert_raises(ArgumentError) do
          pinterest.search(nil)
        end
        assert_match(/query is required/, error.message)
      end

      it "raises ArgumentError when query is empty" do
        error = assert_raises(ArgumentError) do
          pinterest.search("")
        end
        assert_match(/query is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises PaymentRequiredError for invalid API key" do
        VCR.use_cassette("pinterest/search_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::PaymentRequiredError) do
            invalid_client.pinterest.search("test query")
          end

          assert_match(/credits/i, error.message)
        end
      end
    end
  end

  describe "#pin" do
    let(:pin_url) { "https://www.pinterest.com/pin/68747564459/" }

    it "fetches Pinterest pin details successfully" do
      VCR.use_cassette("pinterest/pin_success") do
        result = pinterest.pin(pin_url)

        assert_kind_of Hash, result
        assert result.key?(:success)
        assert result[:success]
      end
    end

    it "returns pin with expected core fields" do
      VCR.use_cassette("pinterest/pin_success") do
        result = pinterest.pin(pin_url)

        assert result.key?(:title)
        assert result.key?(:description)
        assert result.key?(:entity_id)
        assert result.key?(:domain)
      end
    end

    it "returns pin with image specifications" do
      VCR.use_cassette("pinterest/pin_success") do
        result = pinterest.pin(pin_url)

        # Check for various image specs
        assert result.key?(:image_spec_orig) || result.key?(:image_spec_736x)

        assert result[:image_spec_orig].key?(:url) if result[:image_spec_orig]
      end
    end

    it "returns pinner information" do
      VCR.use_cassette("pinterest/pin_success") do
        result = pinterest.pin(pin_url)

        if result[:pinner]
          pinner = result[:pinner]

          assert pinner.key?(:username)
          assert pinner.key?(:full_name)
        end
      end
    end

    it "returns origin pinner information" do
      VCR.use_cassette("pinterest/pin_success") do
        result = pinterest.pin(pin_url)

        if result[:origin_pinner]
          origin_pinner = result[:origin_pinner]

          assert origin_pinner.key?(:username)
          assert origin_pinner.key?(:full_name)
        end
      end
    end

    it "returns board information" do
      VCR.use_cassette("pinterest/pin_success") do
        result = pinterest.pin(pin_url)

        if result[:board]
          board = result[:board]

          assert board.key?(:name)
          assert board.key?(:url)
        end
      end
    end

    it "returns engagement statistics" do
      VCR.use_cassette("pinterest/pin_success") do
        result = pinterest.pin(pin_url)

        # Check for engagement fields
        assert result.key?(:total_reaction_count) || result.key?(:share_count) || result.key?(:repin_count)
      end
    end

    it "returns aggregated pin data" do
      VCR.use_cassette("pinterest/pin_success") do
        result = pinterest.pin(pin_url)

        if result[:aggregated_pin_data]
          aggregated = result[:aggregated_pin_data]

          assert aggregated[:aggregated_stats].key?(:saves) if aggregated[:aggregated_stats]
        end
      end
    end

    it "returns rich metadata when available" do
      VCR.use_cassette("pinterest/pin_success") do
        result = pinterest.pin(pin_url)

        assert_kind_of Hash, result[:rich_metadata] if result[:rich_metadata]
      end
    end

    it "fetches pin with trim parameter" do
      VCR.use_cassette("pinterest/pin_trimmed") do
        result = pinterest.pin(pin_url, trim: true)

        assert_kind_of Hash, result
        assert result.key?(:success)
      end
    end

    describe "argument validation" do
      it "raises ArgumentError when url is nil" do
        error = assert_raises(ArgumentError) do
          pinterest.pin(nil)
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is empty" do
        error = assert_raises(ArgumentError) do
          pinterest.pin("")
        end
        assert_match(/url is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises PaymentRequiredError for invalid API key" do
        VCR.use_cassette("pinterest/pin_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::PaymentRequiredError) do
            invalid_client.pinterest.pin(pin_url)
          end

          assert_match(/credits/i, error.message)
        end
      end
    end
  end

  describe "#user_boards" do
    let(:handle) { "broadstbullycom" }

    it "fetches user boards successfully" do
      VCR.use_cassette("pinterest/user_boards_success") do
        result = pinterest.user_boards(handle)

        assert_kind_of Hash, result
        assert result.key?(:success)
        assert result[:success]
        assert result.key?(:boards)
        assert_kind_of Array, result[:boards]
      end
    end

    it "returns boards with expected core fields" do
      VCR.use_cassette("pinterest/user_boards_success") do
        result = pinterest.user_boards(handle)

        refute_empty result[:boards]
        board = result[:boards].first

        assert board.key?(:id)
        assert board.key?(:name)
        assert board.key?(:url)
        assert board.key?(:pin_count)
      end
    end

    it "returns board owner information" do
      VCR.use_cassette("pinterest/user_boards_success") do
        result = pinterest.user_boards(handle)

        board = result[:boards].first

        if board[:owner]
          owner = board[:owner]

          assert owner.key?(:username)
          assert owner.key?(:full_name)
          assert owner.key?(:id)
        end
      end
    end

    it "returns board metadata" do
      VCR.use_cassette("pinterest/user_boards_success") do
        result = pinterest.user_boards(handle)

        board = result[:boards].first

        assert board.key?(:follower_count)
        assert board.key?(:privacy)
        assert board.key?(:type)
      end
    end

    it "returns board images when available" do
      VCR.use_cassette("pinterest/user_boards_success") do
        result = pinterest.user_boards(handle)

        board = result[:boards].first

        assert_kind_of Hash, board[:images] if board[:images]
      end
    end

    it "returns cover images when available" do
      VCR.use_cassette("pinterest/user_boards_success") do
        result = pinterest.user_boards(handle)

        board = result[:boards].first

        assert_kind_of Hash, board[:cover_images] if board[:cover_images]

        assert board.key?(:image_cover_url) || board.key?(:image_cover_hd_url)
      end
    end

    it "includes pagination cursor in response" do
      VCR.use_cassette("pinterest/user_boards_success") do
        result = pinterest.user_boards(handle)

        assert result.key?(:cursor)
      end
    end

    it "fetches user boards with trim parameter" do
      VCR.use_cassette("pinterest/user_boards_trimmed") do
        result = pinterest.user_boards(handle, trim: true)

        assert_kind_of Hash, result
        assert result.key?(:success)
        assert result.key?(:boards)
      end
    end

    describe "argument validation" do
      it "raises ArgumentError when handle is nil" do
        error = assert_raises(ArgumentError) do
          pinterest.user_boards(nil)
        end
        assert_match(/handle is required/, error.message)
      end

      it "raises ArgumentError when handle is empty" do
        error = assert_raises(ArgumentError) do
          pinterest.user_boards("")
        end
        assert_match(/handle is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises PaymentRequiredError for invalid API key" do
        VCR.use_cassette("pinterest/user_boards_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::PaymentRequiredError) do
            invalid_client.pinterest.user_boards(handle)
          end

          assert_match(/credits/i, error.message)
        end
      end
    end
  end
end
