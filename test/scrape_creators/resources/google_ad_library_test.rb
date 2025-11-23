# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::GoogleAdLibrary do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:google_ad_library) { client.google_ad_library }

  describe "#company_ads" do
    describe "with domain parameter" do
      it "fetches company ads by domain successfully" do
        VCR.use_cassette("google_ad_library/company_ads_by_domain") do
          result = google_ad_library.company_ads(domain: "foreplay.co")

          assert_kind_of Hash, result
          assert result[:success]
          assert result.key?(:credits_remaining)
          assert result.key?(:ads)
          assert_kind_of Array, result[:ads]

          # Verify ads structure if there are ads
          if result[:ads].any?
            ad = result[:ads].first

            assert ad.key?(:advertiser_id)
            assert ad.key?(:creative_id)
          end
        end
      end

      it "returns pagination cursor when more results available" do
        VCR.use_cassette("google_ad_library/company_ads_by_domain") do
          result = google_ad_library.company_ads(domain: "foreplay.co")

          assert_kind_of Hash, result

          # Cursor should be present if there are more results
          refute_empty result[:cursor] if result[:cursor]
        end
      end
    end

    describe "with advertiser_id parameter" do
      it "fetches company ads by advertiser ID successfully" do
        VCR.use_cassette("google_ad_library/company_ads_by_advertiser_id") do
          result = google_ad_library.company_ads(advertiser_id: "AR09628680369637163009")

          assert_kind_of Hash, result
          assert result[:success]
          assert result.key?(:ads)
          assert_kind_of Array, result[:ads]
        end
      end
    end

    describe "with optional parameters" do
      it "accepts topic and region parameters" do
        VCR.use_cassette("google_ad_library/company_ads_with_topic") do
          result = google_ad_library.company_ads(
            domain: "foreplay.co",
            topic: "all"
          )

          assert_kind_of Hash, result
          assert result[:success]
        end
      end

      it "accepts date range parameters" do
        VCR.use_cassette("google_ad_library/company_ads_with_dates") do
          result = google_ad_library.company_ads(
            domain: "foreplay.co",
            start_date: "2024-01-01",
            end_date: "2024-12-31"
          )

          assert_kind_of Hash, result
          assert result[:success]
        end
      end

      it "accepts get_ad_details parameter" do
        VCR.use_cassette("google_ad_library/company_ads_with_details") do
          result = google_ad_library.company_ads(
            domain: "foreplay.co",
            get_ad_details: true
          )

          assert_kind_of Hash, result
          assert result[:success]
        end
      end

      it "accepts cursor for pagination" do
        VCR.use_cassette("google_ad_library/company_ads_with_cursor") do
          result = google_ad_library.company_ads(
            domain: "foreplay.co",
            cursor: "CgoAP7zm82Y5sMRjEhBwPifBwIMxRttsqvUAAAAAGgn8"
          )

          assert_kind_of Hash, result
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when both domain and advertiser_id are nil" do
        error = assert_raises(ArgumentError) do
          google_ad_library.company_ads
        end
        assert_match(/domain or advertiser_id is required/, error.message)
      end

      it "raises ArgumentError when both domain and advertiser_id are empty strings" do
        error = assert_raises(ArgumentError) do
          google_ad_library.company_ads(domain: "", advertiser_id: "")
        end
        assert_match(/domain or advertiser_id is required/, error.message)
      end

      it "raises ArgumentError when topic is political but region is not provided" do
        error = assert_raises(ArgumentError) do
          google_ad_library.company_ads(domain: "example.com", topic: "political")
        end
        assert_match(/region is required when topic is 'political'/, error.message)
      end

      it "raises ArgumentError when topic is Political (case insensitive) but region is not provided" do
        error = assert_raises(ArgumentError) do
          google_ad_library.company_ads(domain: "example.com", topic: "Political")
        end
        assert_match(/region is required when topic is 'political'/, error.message)
      end

      it "does not raise when topic is political and region is provided" do
        VCR.use_cassette("google_ad_library/company_ads_political") do
          result = google_ad_library.company_ads(
            domain: "example.com",
            topic: "political",
            region: "US"
          )

          assert_kind_of Hash, result
        end
      end
    end

    describe "error handling" do
      it "raises UnauthorizedError for invalid API key" do
        VCR.use_cassette("google_ad_library/company_ads_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::UnauthorizedError) do
            invalid_client.google_ad_library.company_ads(domain: "foreplay.co")
          end

          assert_match(/invalid|unauthorized|api.?key/i, error.message)
        end
      end
    end
  end
end
