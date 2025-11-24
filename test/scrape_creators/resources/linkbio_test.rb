# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Linkbio do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:linkbio) { client.linkbio }

  describe "#page" do
    let(:linkbio_url) { "https://lnk.bio/msjennafischer" }

    it "fetches Linkbio page successfully" do
      VCR.use_cassette("linkbio/page_success") do
        result = linkbio.page(linkbio_url)

        assert_kind_of Hash, result
        assert result.key?(:success)
        assert result[:success]
      end
    end

    it "returns expected profile fields" do
      VCR.use_cassette("linkbio/page_success") do
        result = linkbio.page(linkbio_url)

        assert result.key?(:handle)
        assert result.key?(:id)
      end
    end

    it "returns social media link fields" do
      VCR.use_cassette("linkbio/page_success") do
        result = linkbio.page(linkbio_url)

        # Linkbio returns social media fields (may be nil)
        assert result.key?(:instagram) || result.key?(:tiktok) ||
               result.key?(:youtube) || result.key?(:twitter)
      end
    end

    it "returns links array with expected fields" do
      VCR.use_cassette("linkbio/page_success") do
        result = linkbio.page(linkbio_url)

        assert result.key?(:links)
        assert_kind_of Array, result[:links]

        if result[:links].any?
          link = result[:links].first

          assert link.key?(:url)
          assert link.key?(:text)
        end
      end
    end

    describe "argument validation" do
      it "raises ArgumentError when url is nil" do
        error = assert_raises(ArgumentError) do
          linkbio.page(nil)
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is empty" do
        error = assert_raises(ArgumentError) do
          linkbio.page("")
        end
        assert_match(/url is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises PaymentRequiredError for invalid API key" do
        VCR.use_cassette("linkbio/page_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::PaymentRequiredError) do
            invalid_client.linkbio.page(linkbio_url)
          end

          assert_match(/credits/i, error.message)
        end
      end
    end
  end
end
