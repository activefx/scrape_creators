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

  describe "#search_ads" do
    describe "with valid query" do
      it "searches ads successfully" do
        VCR.use_cassette("facebook_ad_library/search_ads_success") do
          result = facebook_ad_library.search_ads(query: "labradoodle")

          assert_kind_of Hash, result
          assert result.key?(:search_results)
          assert result.key?(:search_results_count)
          assert_kind_of Array, result[:search_results]
        end
      end

      it "returns ad details in search results" do
        VCR.use_cassette("facebook_ad_library/search_ads_success") do
          result = facebook_ad_library.search_ads(query: "labradoodle")

          refute_empty result[:search_results]
          ad = result[:search_results].first

          assert ad.key?(:ad_archive_id)
          assert ad.key?(:page_name)
          assert ad.key?(:snapshot)
        end
      end

      it "returns pagination cursor" do
        VCR.use_cassette("facebook_ad_library/search_ads_success") do
          result = facebook_ad_library.search_ads(query: "labradoodle")

          assert result.key?(:cursor)
        end
      end
    end

    describe "with optional parameters" do
      it "accepts country filter" do
        VCR.use_cassette("facebook_ad_library/search_ads_with_country") do
          result = facebook_ad_library.search_ads(
            query: "coffee",
            country: "US"
          )

          assert_kind_of Hash, result
          assert result.key?(:search_results)
        end
      end

      it "accepts status filter" do
        VCR.use_cassette("facebook_ad_library/search_ads_with_status") do
          result = facebook_ad_library.search_ads(
            query: "coffee",
            status: "ACTIVE"
          )

          assert_kind_of Hash, result
          assert result.key?(:search_results)
        end
      end

      it "accepts media_type filter" do
        VCR.use_cassette("facebook_ad_library/search_ads_with_media_type") do
          result = facebook_ad_library.search_ads(
            query: "coffee",
            media_type: "VIDEO"
          )

          assert_kind_of Hash, result
          assert result.key?(:search_results)
        end
      end

      it "accepts search_type parameter" do
        VCR.use_cassette("facebook_ad_library/search_ads_exact_phrase") do
          result = facebook_ad_library.search_ads(
            query: "organic coffee",
            search_type: "keyword_exact_phrase"
          )

          assert_kind_of Hash, result
          assert result.key?(:search_results)
        end
      end

      it "accepts date range filters" do
        VCR.use_cassette("facebook_ad_library/search_ads_with_dates") do
          result = facebook_ad_library.search_ads(
            query: "coffee",
            start_date: "2025-01-01",
            end_date: "2025-11-01"
          )

          assert_kind_of Hash, result
          assert result.key?(:search_results)
        end
      end

      it "accepts trim parameter" do
        VCR.use_cassette("facebook_ad_library/search_ads_trimmed") do
          result = facebook_ad_library.search_ads(
            query: "coffee",
            trim: true
          )

          assert_kind_of Hash, result
          assert result.key?(:search_results)
        end
      end

      it "accepts cursor for pagination" do
        VCR.use_cassette("facebook_ad_library/search_ads_with_cursor") do
          result = facebook_ad_library.search_ads(
            query: "coffee",
            cursor: "AQHRYLVDkoMkvGv7yK1rcce"
          )

          assert_kind_of Hash, result
          assert result.key?(:search_results)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when query is nil" do
        error = assert_raises(ArgumentError) do
          facebook_ad_library.search_ads(query: nil)
        end
        assert_match(/query is required/, error.message)
      end

      it "raises ArgumentError when query is empty string" do
        error = assert_raises(ArgumentError) do
          facebook_ad_library.search_ads(query: "")
        end
        assert_match(/query is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises PaymentRequiredError for invalid API key" do
        VCR.use_cassette("facebook_ad_library/search_ads_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::PaymentRequiredError) do
            invalid_client.facebook_ad_library.search_ads(query: "test")
          end

          assert_match(/credits/i, error.message)
        end
      end
    end
  end

  describe "#company_ads" do
    describe "with valid page_id" do
      it "fetches company ads successfully" do
        VCR.use_cassette("facebook_ad_library/company_ads_success") do
          result = facebook_ad_library.company_ads(page_id: "367152833370567")

          assert_kind_of Hash, result
          assert result.key?(:results)
          assert_kind_of Array, result[:results]
        end
      end

      it "returns ad details in results" do
        VCR.use_cassette("facebook_ad_library/company_ads_success") do
          result = facebook_ad_library.company_ads(page_id: "367152833370567")

          refute_empty result[:results]
          ad = result[:results].first

          assert ad.key?(:ad_archive_id)
          assert ad.key?(:page_name)
          assert ad.key?(:snapshot)
        end
      end

      it "returns pagination cursor" do
        VCR.use_cassette("facebook_ad_library/company_ads_success") do
          result = facebook_ad_library.company_ads(page_id: "367152833370567")

          assert result.key?(:cursor)
        end
      end
    end

    describe "with valid company_name" do
      it "fetches company ads by name" do
        VCR.use_cassette("facebook_ad_library/company_ads_by_name") do
          result = facebook_ad_library.company_ads(company_name: "Instagram")

          assert_kind_of Hash, result
          assert result.key?(:results)
          assert_kind_of Array, result[:results]
        end
      end
    end

    describe "with optional parameters" do
      it "accepts country filter" do
        VCR.use_cassette("facebook_ad_library/company_ads_with_country") do
          result = facebook_ad_library.company_ads(
            page_id: "367152833370567",
            country: "US"
          )

          assert_kind_of Hash, result
          assert result.key?(:results)
        end
      end

      it "accepts status filter" do
        VCR.use_cassette("facebook_ad_library/company_ads_with_status") do
          result = facebook_ad_library.company_ads(
            page_id: "367152833370567",
            status: "ACTIVE"
          )

          assert_kind_of Hash, result
          assert result.key?(:results)
        end
      end

      it "accepts media_type filter" do
        VCR.use_cassette("facebook_ad_library/company_ads_with_media_type") do
          result = facebook_ad_library.company_ads(
            page_id: "367152833370567",
            media_type: "VIDEO"
          )

          assert_kind_of Hash, result
          assert result.key?(:results)
        end
      end

      it "accepts trim parameter" do
        VCR.use_cassette("facebook_ad_library/company_ads_trimmed") do
          result = facebook_ad_library.company_ads(
            page_id: "367152833370567",
            trim: true
          )

          assert_kind_of Hash, result
          assert result.key?(:results)
        end
      end

      it "accepts cursor for pagination" do
        VCR.use_cassette("facebook_ad_library/company_ads_with_cursor") do
          result = facebook_ad_library.company_ads(
            page_id: "367152833370567",
            cursor: "AQHRBUAxNmFlxBVMFL6u"
          )

          assert_kind_of Hash, result
          assert result.key?(:results)
        end
      end

      it "accepts language filter" do
        VCR.use_cassette("facebook_ad_library/company_ads_with_language") do
          result = facebook_ad_library.company_ads(
            page_id: "367152833370567",
            language: "EN"
          )

          assert_kind_of Hash, result
          assert result.key?(:results)
        end
      end

      it "accepts start_date filter" do
        VCR.use_cassette("facebook_ad_library/company_ads_with_start_date") do
          result = facebook_ad_library.company_ads(
            page_id: "367152833370567",
            start_date: "2025-01-01"
          )

          assert_kind_of Hash, result
          assert result.key?(:results)
        end
      end

      it "accepts end_date filter" do
        VCR.use_cassette("facebook_ad_library/company_ads_with_end_date") do
          result = facebook_ad_library.company_ads(
            page_id: "367152833370567",
            end_date: "2025-12-31"
          )

          assert_kind_of Hash, result
          assert result.key?(:results)
        end
      end

      it "accepts date range and language filters together" do
        VCR.use_cassette("facebook_ad_library/company_ads_with_date_range_and_language") do
          result = facebook_ad_library.company_ads(
            page_id: "367152833370567",
            language: "ES",
            start_date: "2025-01-01",
            end_date: "2025-12-31"
          )

          assert_kind_of Hash, result
          assert result.key?(:results)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when both page_id and company_name are nil" do
        error = assert_raises(ArgumentError) do
          facebook_ad_library.company_ads(page_id: nil, company_name: nil)
        end
        assert_match(/Either page_id or company_name is required/, error.message)
      end

      it "raises ArgumentError when both page_id and company_name are empty strings" do
        error = assert_raises(ArgumentError) do
          facebook_ad_library.company_ads(page_id: "", company_name: "")
        end
        assert_match(/Either page_id or company_name is required/, error.message)
      end

      it "raises ArgumentError when no parameters provided" do
        error = assert_raises(ArgumentError) do
          facebook_ad_library.company_ads
        end
        assert_match(/Either page_id or company_name is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises UnauthorizedError for invalid API key" do
        VCR.use_cassette("facebook_ad_library/company_ads_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::UnauthorizedError) do
            invalid_client.facebook_ad_library.company_ads(page_id: "367152833370567")
          end

          assert_match(/invalid|unauthorized|api.?key/i, error.message)
        end
      end

      it "raises NotFoundError for non-existent company" do
        VCR.use_cassette("facebook_ad_library/company_ads_not_found") do
          error = assert_raises(ScrapeCreators::NotFoundError) do
            facebook_ad_library.company_ads(page_id: "999999999999999")
          end

          assert_match(/not found/i, error.message)
        end
      end
    end
  end

  describe "#search_companies" do
    describe "with valid query" do
      it "searches companies successfully" do
        VCR.use_cassette("facebook_ad_library/search_companies_success") do
          result = facebook_ad_library.search_companies(query: "Nike")

          assert_kind_of Hash, result
          assert result.key?(:search_results)
          assert_kind_of Array, result[:search_results]
        end
      end

      it "returns company details in search results" do
        VCR.use_cassette("facebook_ad_library/search_companies_success") do
          result = facebook_ad_library.search_companies(query: "Nike")

          refute_empty result[:search_results]
          company = result[:search_results].first

          assert company.key?(:page_id)
          assert company.key?(:name)
          assert company.key?(:category)
        end
      end

      it "returns Instagram information when available" do
        VCR.use_cassette("facebook_ad_library/search_companies_success") do
          result = facebook_ad_library.search_companies(query: "Nike")

          refute_empty result[:search_results]
          company = result[:search_results].first

          assert company.key?(:ig_username)
          assert company.key?(:ig_followers)
          assert company.key?(:ig_verification)
        end
      end

      it "returns verification status" do
        VCR.use_cassette("facebook_ad_library/search_companies_success") do
          result = facebook_ad_library.search_companies(query: "Nike")

          refute_empty result[:search_results]
          company = result[:search_results].first

          assert company.key?(:verification)
          assert company.key?(:likes)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when query is nil" do
        error = assert_raises(ArgumentError) do
          facebook_ad_library.search_companies(query: nil)
        end
        assert_match(/query is required/, error.message)
      end

      it "raises ArgumentError when query is empty string" do
        error = assert_raises(ArgumentError) do
          facebook_ad_library.search_companies(query: "")
        end
        assert_match(/query is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises UnauthorizedError for invalid API key" do
        VCR.use_cassette("facebook_ad_library/search_companies_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::UnauthorizedError) do
            invalid_client.facebook_ad_library.search_companies(query: "Nike")
          end

          assert_match(/invalid|unauthorized|api.?key/i, error.message)
        end
      end
    end
  end
end
