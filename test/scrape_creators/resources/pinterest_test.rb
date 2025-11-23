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
end
