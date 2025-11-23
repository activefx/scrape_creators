# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::LinkedinAdLibrary do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:linkedin_ad_library) { client.linkedin_ad_library }

  describe "#search" do
    describe "with company parameter" do
      it "searches ads by company name successfully" do
        VCR.use_cassette("linkedin_ad_library/search_by_company") do
          result = linkedin_ad_library.search(company: "Microsoft")

          assert_kind_of Hash, result
          assert result[:success]
          assert result.key?(:ads)
          assert_kind_of Array, result[:ads]

          if result[:ads].any?
            ad = result[:ads].first

            assert ad.key?(:id)
            assert ad.key?(:description)
            assert ad.key?(:advertiser)
            assert ad.key?(:ad_type)
          end
        end
      end

      it "returns pagination info when more results available" do
        VCR.use_cassette("linkedin_ad_library/search_by_company") do
          result = linkedin_ad_library.search(company: "Microsoft")

          assert_kind_of Hash, result
          assert result.key?(:pagination_token)
          assert result.key?(:is_last_page)
        end
      end
    end

    describe "with keyword parameter" do
      it "searches ads by keyword successfully" do
        VCR.use_cassette("linkedin_ad_library/search_by_keyword") do
          result = linkedin_ad_library.search(keyword: "cloud computing")

          assert_kind_of Hash, result
          assert result[:success]
          assert result.key?(:ads)
          assert_kind_of Array, result[:ads]
        end
      end
    end

    describe "with optional parameters" do
      it "accepts countries parameter" do
        VCR.use_cassette("linkedin_ad_library/search_with_countries") do
          result = linkedin_ad_library.search(
            company: "Microsoft",
            countries: "US,CA"
          )

          assert_kind_of Hash, result
          assert result[:success]
        end
      end

      it "accepts date range parameters" do
        VCR.use_cassette("linkedin_ad_library/search_with_dates") do
          result = linkedin_ad_library.search(
            company: "Microsoft",
            start_date: "2024-01-01",
            end_date: "2024-12-31"
          )

          assert_kind_of Hash, result
          assert result[:success]
        end
      end

      it "accepts pagination_token for pagination" do
        VCR.use_cassette("linkedin_ad_library/search_with_pagination") do
          result = linkedin_ad_library.search(
            company: "Microsoft",
            pagination_token: "756412693-1754569518292"
          )

          assert_kind_of Hash, result
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when both company and keyword are nil" do
        error = assert_raises(ArgumentError) do
          linkedin_ad_library.search
        end
        assert_match(/company or keyword is required/, error.message)
      end

      it "raises ArgumentError when both company and keyword are empty strings" do
        error = assert_raises(ArgumentError) do
          linkedin_ad_library.search(company: "", keyword: "")
        end
        assert_match(/company or keyword is required/, error.message)
      end

      it "accepts company alone" do
        VCR.use_cassette("linkedin_ad_library/search_by_company") do
          result = linkedin_ad_library.search(company: "Microsoft")

          assert_kind_of Hash, result
        end
      end

      it "accepts keyword alone" do
        VCR.use_cassette("linkedin_ad_library/search_by_keyword") do
          result = linkedin_ad_library.search(keyword: "cloud computing")

          assert_kind_of Hash, result
        end
      end
    end

    describe "error handling" do
      it "raises UnauthorizedError for invalid API key" do
        VCR.use_cassette("linkedin_ad_library/search_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::UnauthorizedError) do
            invalid_client.linkedin_ad_library.search(company: "Microsoft")
          end

          assert_match(/invalid|unauthorized|api.?key/i, error.message)
        end
      end
    end
  end

  describe "#ad" do
    let(:ad_url) { "https://www.linkedin.com/ad-library/detail/664291126" }

    describe "successful request" do
      it "fetches ad details successfully" do
        VCR.use_cassette("linkedin_ad_library/ad_success") do
          result = linkedin_ad_library.ad(url: ad_url)

          assert_kind_of Hash, result
          assert result[:success]
          assert result.key?(:id)
          assert result.key?(:description)
          assert result.key?(:advertiser)
          assert result.key?(:ad_type)
        end
      end

      it "returns targeting information" do
        VCR.use_cassette("linkedin_ad_library/ad_success") do
          result = linkedin_ad_library.ad(url: ad_url)

          assert result.key?(:targeting)
          assert_kind_of Hash, result[:targeting]
        end
      end

      it "returns impression data" do
        VCR.use_cassette("linkedin_ad_library/ad_success") do
          result = linkedin_ad_library.ad(url: ad_url)

          assert result.key?(:total_impressions)
          assert result.key?(:impressions_by_country)
          assert_kind_of Array, result[:impressions_by_country]
        end
      end

      it "returns date information" do
        VCR.use_cassette("linkedin_ad_library/ad_success") do
          result = linkedin_ad_library.ad(url: ad_url)

          assert result.key?(:start_date)
          assert result.key?(:end_date)
          assert result.key?(:ad_duration)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when url is nil" do
        error = assert_raises(ArgumentError) do
          linkedin_ad_library.ad(url: nil)
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is empty string" do
        error = assert_raises(ArgumentError) do
          linkedin_ad_library.ad(url: "")
        end
        assert_match(/url is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises UnauthorizedError for invalid API key" do
        VCR.use_cassette("linkedin_ad_library/ad_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::UnauthorizedError) do
            invalid_client.linkedin_ad_library.ad(url: ad_url)
          end

          assert_match(/invalid|unauthorized|api.?key/i, error.message)
        end
      end
    end
  end
end
