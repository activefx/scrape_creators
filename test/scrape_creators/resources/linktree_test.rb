# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Linktree do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:linktree) { client.linktree }

  describe "#page" do
    let(:linktree_url) { "https://linktr.ee/miguelangeles" }

    it "fetches Linktree page successfully" do
      VCR.use_cassette("linktree/page_success") do
        result = linktree.page(linktree_url)

        assert_kind_of Hash, result
        assert result.key?(:success)
        assert result[:success]
      end
    end

    it "returns expected profile fields" do
      VCR.use_cassette("linktree/page_success") do
        result = linktree.page(linktree_url)

        assert result.key?(:id)
        assert result.key?(:username)
        assert result.key?(:profile_picture_url)
        assert result.key?(:description)
      end
    end

    it "returns social media links" do
      VCR.use_cassette("linktree/page_success") do
        result = linktree.page(linktree_url)

        # Check for social media platform links
        assert result.key?(:instagram) || result.key?(:tiktok) || result.key?(:spotify)
      end
    end

    it "returns links array with expected fields" do
      VCR.use_cassette("linktree/page_success") do
        result = linktree.page(linktree_url)

        assert result.key?(:links)
        assert_kind_of Array, result[:links]

        if result[:links].any?
          link = result[:links].first

          assert link.key?(:id)
          assert link.key?(:type)
          assert link.key?(:title)
        end
      end
    end

    it "returns verticals and link platforms" do
      VCR.use_cassette("linktree/page_success") do
        result = linktree.page(linktree_url)

        assert result.key?(:verticals)
        assert result.key?(:link_platforms)
        assert_kind_of Array, result[:verticals]
        assert_kind_of Array, result[:link_platforms]
      end
    end

    describe "argument validation" do
      it "raises ArgumentError when url is nil" do
        error = assert_raises(ArgumentError) do
          linktree.page(nil)
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is empty" do
        error = assert_raises(ArgumentError) do
          linktree.page("")
        end
        assert_match(/url is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises PaymentRequiredError for invalid API key" do
        VCR.use_cassette("linktree/page_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::PaymentRequiredError) do
            invalid_client.linktree.page(linktree_url)
          end

          assert_match(/credits/i, error.message)
        end
      end
    end
  end
end
