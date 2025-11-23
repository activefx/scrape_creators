# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Google do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:google) { client.google }

  describe "#search" do
    it "searches Google successfully" do
      VCR.use_cassette("google/search_success") do
        result = google.search("Austen Allred")

        assert_kind_of Hash, result
        assert result.key?(:success)
        assert result.key?(:results)
        assert_kind_of Array, result[:results]
        refute_empty result[:results]
      end
    end

    it "returns results with expected fields" do
      VCR.use_cassette("google/search_success") do
        result = google.search("Austen Allred")

        search_result = result[:results].first

        assert search_result.key?(:url)
        assert search_result.key?(:title)
        assert search_result.key?(:description)
      end
    end

    it "searches with region parameter" do
      VCR.use_cassette("google/search_with_region") do
        result = google.search("technology news", region: "UK")

        assert_kind_of Hash, result
        assert result.key?(:success)
        assert result.key?(:results)
        assert_kind_of Array, result[:results]
      end
    end

    describe "argument validation" do
      it "raises ArgumentError when query is nil" do
        error = assert_raises(ArgumentError) do
          google.search(nil)
        end
        assert_match(/query is required/, error.message)
      end

      it "raises ArgumentError when query is empty" do
        error = assert_raises(ArgumentError) do
          google.search("")
        end
        assert_match(/query is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises PaymentRequiredError for invalid API key" do
        VCR.use_cassette("google/search_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::PaymentRequiredError) do
            invalid_client.google.search("test query")
          end

          assert_match(/credits/i, error.message)
        end
      end
    end
  end
end
