# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::FacebookAdLibrary do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:facebook_ad_library) { client.facebook_ad_library }

  describe "#ad" do
    describe "with valid ad ID" do
      it "fetches ad details successfully" do
        VCR.use_cassette("facebook_ad_library/ad_success") do
          result = facebook_ad_library.ad(id: "702369045530963")

          assert_kind_of Hash, result
          assert result.key?(:ad_archive_id)
          assert result.key?(:page_name)
          assert result.key?(:snapshot)
          assert result.key?(:url)
        end
      end

      it "returns ad snapshot data" do
        VCR.use_cassette("facebook_ad_library/ad_success") do
          result = facebook_ad_library.ad(id: "702369045530963")

          assert_kind_of Hash, result[:snapshot]
          assert result[:snapshot].key?(:body)
          assert result[:snapshot].key?(:display_format)
        end
      end

      it "returns publisher platform information" do
        VCR.use_cassette("facebook_ad_library/ad_success") do
          result = facebook_ad_library.ad(id: "702369045530963")

          assert result.key?(:publisher_platform)
        end
      end
    end

    describe "with optional parameters" do
      it "accepts get_transcript parameter" do
        VCR.use_cassette("facebook_ad_library/ad_with_transcript") do
          result = facebook_ad_library.ad(
            id: "702369045530963",
            get_transcript: true
          )

          assert_kind_of Hash, result
          assert result.key?(:ad_archive_id)
        end
      end

      it "accepts trim parameter" do
        VCR.use_cassette("facebook_ad_library/ad_trimmed") do
          result = facebook_ad_library.ad(
            id: "702369045530963",
            trim: true
          )

          assert_kind_of Hash, result
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when id is nil" do
        error = assert_raises(ArgumentError) do
          facebook_ad_library.ad(id: nil)
        end
        assert_match(/id is required/, error.message)
      end

      it "raises ArgumentError when id is empty string" do
        error = assert_raises(ArgumentError) do
          facebook_ad_library.ad(id: "")
        end
        assert_match(/id is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises UnauthorizedError for invalid API key" do
        VCR.use_cassette("facebook_ad_library/ad_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::UnauthorizedError) do
            invalid_client.facebook_ad_library.ad(id: "702369045530963")
          end

          assert_match(/invalid|unauthorized|api.?key/i, error.message)
        end
      end

      it "raises NotFoundError for non-existent ad" do
        VCR.use_cassette("facebook_ad_library/ad_not_found") do
          error = assert_raises(ScrapeCreators::NotFoundError) do
            facebook_ad_library.ad(id: "999999999999999")
          end

          assert_match(/not found/i, error.message)
        end
      end
    end
  end
end
