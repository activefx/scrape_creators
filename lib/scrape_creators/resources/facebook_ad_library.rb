# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Facebook Ad Library API resource
    #
    # Provides methods to interact with Facebook Ad Library endpoints for retrieving
    # ad details, searching ads, and accessing company ad information.
    #
    # @see https://docs.scrapecreators.com/v1/facebook-ad-library Facebook Ad Library API Documentation
    class FacebookAdLibrary < Resource
      # Get details about a Facebook ad
      #
      # Retrieves detailed information about a specific ad from the Facebook Ad Library.
      # You can identify the ad either by its ID or by passing the full Facebook Ad Library URL.
      # Be careful that if an ad has multiple versions, you'll want to get the title
      # from the 'cards' object in the snapshot.
      #
      # @param id [String, nil] The Facebook Ad ID. Can use this or url.
      # @param url [String, nil] The Facebook Ad Library URL. Can use this or id.
      # @param get_transcript [Boolean, nil] Get the transcript of the ad. This is a new feature.
      # @param trim [Boolean, nil] Set to true for a trimmed down version of the response
      # @return [Hash] Response containing ad details including snapshot, targeting info, and metadata
      # @raise [ArgumentError] If neither id nor url is provided
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      # @raise [NotFoundError] If the ad is not found
      #
      # @example Get ad details by ID
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.facebook_ad_library.ad(id: "702369045530963")
      #   puts result[:page_name]  # => "Porto Montenegro"
      #   puts result[:snapshot][:body]  # => Ad body text
      #
      # @example Get ad details by URL
      #   result = client.facebook_ad_library.ad(
      #     url: "https://www.facebook.com/ads/library/?id=702369045530963"
      #   )
      #   puts result[:page_name]  # => "Porto Montenegro"
      #
      # @example Get ad with transcript
      #   result = client.facebook_ad_library.ad(
      #     id: "702369045530963",
      #     get_transcript: true
      #   )
      #
      # @example Get trimmed response
      #   result = client.facebook_ad_library.ad(
      #     id: "702369045530963",
      #     trim: true
      #   )
      #
      # @example Response structure (key fields)
      #   {
      #     ad_archive_id: 702369045530963,
      #     page_id: 166258896830103,
      #     page_name: "Porto Montenegro",
      #     is_active: false,
      #     start_date: 1747897200,
      #     end_date: 1747983600,
      #     start_date_string: "2025-05-22T07:00:00.000Z",
      #     end_date_string: "2025-05-23T07:00:00.000Z",
      #     publisher_platform: ["facebook", "instagram", "audience_network"],
      #     url: "https://www.facebook.com/ads/library?id=702369045530963",
      #     snapshot: {
      #       display_format: "video",
      #       body: "Ad body text...",
      #       caption: "www.example.com",
      #       cta_text: "Learn more",
      #       link_url: "https://...",
      #       videos: [...],
      #       images: [...],
      #       cards: [...]
      #     },
      #     aaa_info: {
      #       targets_eu: true,
      #       location_audience: [...],
      #       gender_audience: "All",
      #       age_audience: { min: 18, max: 65 },
      #       eu_total_reach: 1657
      #     }
      #   }
      def ad(id: nil, url: nil, get_transcript: nil, trim: nil)
        validate_ad_params!(id, url)

        params = build_ad_params(id, url, get_transcript, trim)
        get("/v1/facebook/adLibrary/ad", params)
      end

      # Search the Facebook (Meta) Ad Library by keyword
      #
      # Searches the Facebook Ad Library for ads matching a keyword query. Returns paginated
      # results with ad details including creative content, targeting, and publisher platforms.
      #
      # @note This endpoint will tap out around 1,500 results because the cursor becomes too
      #   big for a GET request. If you need more results, use the POST variant by passing
      #   query params in the body.
      #
      # @param query [String] Keyword to search for (required)
      # @param search_type [String, nil] Search type: "keyword_unordered" or "keyword_exact_phrase"
      # @param ad_type [String, nil] Ad type filter: "all" or "political_and_issue_ads"
      # @param country [String, nil] Two-letter country code (e.g., "US", "GB"). Defaults to ALL
      # @param status [String, nil] Ad status: "ALL", "ACTIVE", or "INACTIVE". Defaults to ACTIVE
      # @param media_type [String, nil] Media type: "ALL", "IMAGE", "VIDEO", "MEME",
      #   "IMAGE_AND_MEME", or "NONE". Defaults to ALL
      # @param start_date [String, nil] Impressions start date in YYYY-MM-DD format
      # @param end_date [String, nil] Impressions end date in YYYY-MM-DD format
      # @param cursor [String, nil] Cursor to paginate through results
      # @param trim [Boolean, nil] Set to true for a trimmed down version of the response
      # @return [Hash] Response containing search_results array, search_results_count, and cursor
      # @raise [ArgumentError] If query is not provided
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Basic keyword search
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.facebook_ad_library.search_ads(query: "labradoodle")
      #   puts result[:search_results_count]  # => 50001
      #   result[:search_results].each { |ad| puts ad[:page_name] }
      #
      # @example Search with filters
      #   result = client.facebook_ad_library.search_ads(
      #     query: "electric cars",
      #     country: "US",
      #     status: "ACTIVE",
      #     media_type: "VIDEO"
      #   )
      #
      # @example Paginate through results
      #   first_page = client.facebook_ad_library.search_ads(query: "fitness")
      #   if first_page[:cursor]
      #     next_page = client.facebook_ad_library.search_ads(
      #       query: "fitness",
      #       cursor: first_page[:cursor]
      #     )
      #   end
      #
      # @example Search for exact phrase
      #   result = client.facebook_ad_library.search_ads(
      #     query: "organic dog food",
      #     search_type: "keyword_exact_phrase"
      #   )
      #
      # @example Response structure (key fields)
      #   {
      #     search_results: [
      #       {
      #         ad_archive_id: "615470338018648",
      #         page_id: "115531458627129",
      #         page_name: "JNB Stables Labradoodles",
      #         is_active: true,
      #         start_date: 1740729600,
      #         end_date: 1740729600,
      #         publisher_platform: ["FACEBOOK", "INSTAGRAM"],
      #         snapshot: {
      #           body: { text: "Ad body text..." },
      #           display_format: "MULTI_IMAGES",
      #           images: [...],
      #           videos: [...]
      #         }
      #       }
      #     ],
      #     search_results_count: 50001,
      #     cursor: "AQHRYLVDkoMkvGv7yK1rcce-vJmKiKv..."
      #   }
      # rubocop:disable Metrics/ParameterLists
      def search_ads(
        query:,
        search_type: nil,
        ad_type: nil,
        country: nil,
        status: nil,
        media_type: nil,
        start_date: nil,
        end_date: nil,
        cursor: nil,
        trim: nil
      )
        validate_search_params!(query)

        params = build_search_params(
          query, search_type, ad_type, country, status,
          media_type, start_date, end_date, cursor, trim
        )
        get("/v1/facebook/adLibrary/search/ads", params)
      end
      # rubocop:enable Metrics/ParameterLists

      # Get all ads a company has running
      #
      # Retrieves all ads from a company's Facebook Ad Library page. You can identify
      # the company either by their page ID or company name.
      #
      # @param page_id [String, nil] The company's ad library page ID. Can use this or company_name
      # @param company_name [String, nil] The name of the company. Can use this or page_id
      # @param country [String, nil] Two-letter country code (e.g., "US", "GB"). Defaults to ALL
      # @param status [String, nil] Ad status: "ALL", "ACTIVE", or "INACTIVE". Defaults to ACTIVE
      # @param media_type [String, nil] Media type: "ALL", "IMAGE", "VIDEO", "MEME",
      #   "IMAGE_AND_MEME", or "NONE". Defaults to ALL. Note: MEME refers to ads with image and text
      # @param language [String, nil] Two-letter language code to filter ads (e.g., "EN", "ES", "FR")
      # @param start_date [String, nil] Start date to search for in YYYY-MM-DD format
      # @param end_date [String, nil] End date to search for in YYYY-MM-DD format
      # @param cursor [String, nil] Cursor to paginate through results
      # @param trim [Boolean, nil] Set to true for a trimmed down version of the response
      # @return [Hash] Response containing results array and cursor for pagination
      # @raise [ArgumentError] If neither page_id nor company_name is provided
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      # @raise [NotFoundError] If the company is not found
      #
      # @example Get company ads by page ID
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.facebook_ad_library.company_ads(page_id: "367152833370567")
      #   puts result[:results].first[:page_name]  # => "Instagram"
      #
      # @example Get company ads by company name
      #   result = client.facebook_ad_library.company_ads(company_name: "Instagram")
      #   result[:results].each { |ad| puts ad[:ad_archive_id] }
      #
      # @example Get company ads with filters
      #   result = client.facebook_ad_library.company_ads(
      #     page_id: "367152833370567",
      #     country: "US",
      #     status: "ACTIVE",
      #     media_type: "VIDEO"
      #   )
      #
      # @example Get company ads with date and language filters
      #   result = client.facebook_ad_library.company_ads(
      #     page_id: "367152833370567",
      #     language: "EN",
      #     start_date: "2025-01-01",
      #     end_date: "2025-12-31"
      #   )
      #
      # @example Paginate through results
      #   first_page = client.facebook_ad_library.company_ads(page_id: "367152833370567")
      #   if first_page[:cursor]
      #     next_page = client.facebook_ad_library.company_ads(
      #       page_id: "367152833370567",
      #       cursor: first_page[:cursor]
      #     )
      #   end
      #
      # @example Response structure (key fields)
      #   {
      #     results: [
      #       {
      #         ad_archive_id: "1162496978867592",
      #         page_id: "367152833370567",
      #         page_name: "Instagram",
      #         is_active: true,
      #         start_date: 1740643200,
      #         end_date: 1740902400,
      #         publisher_platform: ["INSTAGRAM"],
      #         snapshot: {
      #           body: { text: "Ad body text..." },
      #           display_format: "VIDEO",
      #           cta_text: "Learn more",
      #           videos: [...],
      #           images: [...]
      #         }
      #       }
      #     ],
      #     cursor: "AQHRBUAxNmFlxBVMFL6uTb1ICFsV65O4..."
      #   }
      # rubocop:disable Metrics/ParameterLists
      def company_ads(
        page_id: nil,
        company_name: nil,
        country: nil,
        status: nil,
        media_type: nil,
        language: nil,
        start_date: nil,
        end_date: nil,
        cursor: nil,
        trim: nil
      )
        validate_company_ads_params!(page_id, company_name)

        params = build_company_ads_params(
          page_id, company_name, country, status, media_type,
          language, start_date, end_date, cursor, trim
        )
        get("/v1/facebook/adLibrary/company/ads", params)
      end
      # rubocop:enable Metrics/ParameterLists

      # Search for companies by name in the Facebook Ad Library
      #
      # Searches for companies/pages by name and returns their ad library page IDs
      # along with other information like category, likes, and Instagram data.
      #
      # @param query [String] Keyword to search for (required)
      # @return [Hash] Response containing search_results array with company information
      # @raise [ArgumentError] If query is not provided
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Search for companies by name
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.facebook_ad_library.search_companies(query: "Nike")
      #   result[:search_results].each do |company|
      #     puts "#{company[:name]} - Page ID: #{company[:page_id]}"
      #   end
      #
      # @example Response structure (key fields)
      #   {
      #     search_results: [
      #       {
      #         page_id: "51212153078",
      #         category: "Product/service",
      #         image_uri: "https://scontent.ford4-1.fna.fbcdn.net/...",
      #         likes: 41136495,
      #         verification: "BLUE_VERIFIED",
      #         name: "Nike Football",
      #         country: nil,
      #         entity_type: "PERSON_PROFILE",
      #         ig_username: "nikefootball",
      #         ig_followers: 46451228,
      #         ig_verification: true,
      #         page_alias: "nikefootball",
      #         page_is_deleted: false
      #       }
      #     ]
      #   }
      def search_companies(query:)
        validate_search_companies_params!(query)

        params = { query: query }
        get("/v1/facebook/adLibrary/search/companies", params)
      end

      private

      def validate_ad_params!(id, url)
        return unless blank?(id) && blank?(url)

        raise ArgumentError, "Either id or url is required"
      end

      def validate_search_params!(query)
        raise ArgumentError, "query is required" if blank?(query)
      end

      def validate_company_ads_params!(page_id, company_name)
        return unless blank?(page_id) && blank?(company_name)

        raise ArgumentError, "Either page_id or company_name is required"
      end

      def validate_search_companies_params!(query)
        raise ArgumentError, "query is required" if blank?(query)
      end

      def build_ad_params(id, url, get_transcript, trim)
        params = {}
        params[:id] = id unless id.nil?
        params[:url] = url unless url.nil?
        params[:get_transcript] = get_transcript unless get_transcript.nil?
        params[:trim] = trim unless trim.nil?
        params
      end

      # rubocop:disable Metrics/ParameterLists
      def build_search_params(
        query, search_type, ad_type, country, status,
        media_type, start_date, end_date, cursor, trim
      )
        params = { query: query }
        params[:search_type] = search_type unless search_type.nil?
        params[:ad_type] = ad_type unless ad_type.nil?
        params[:country] = country unless country.nil?
        params[:status] = status unless status.nil?
        params[:media_type] = media_type unless media_type.nil?
        params[:start_date] = start_date unless start_date.nil?
        params[:end_date] = end_date unless end_date.nil?
        params[:cursor] = cursor unless cursor.nil?
        params[:trim] = trim unless trim.nil?
        params
      end
      # rubocop:enable Metrics/ParameterLists

      # rubocop:disable Metrics/ParameterLists
      def build_company_ads_params(
        page_id, company_name, country, status, media_type,
        language, start_date, end_date, cursor, trim
      )
        params = {}
        params[:pageId] = page_id unless page_id.nil?
        params[:companyName] = company_name unless company_name.nil?
        params[:country] = country unless country.nil?
        params[:status] = status unless status.nil?
        params[:media_type] = media_type unless media_type.nil?
        params[:language] = language unless language.nil?
        params[:start_date] = start_date unless start_date.nil?
        params[:end_date] = end_date unless end_date.nil?
        params[:cursor] = cursor unless cursor.nil?
        params[:trim] = trim unless trim.nil?
        params
      end
      # rubocop:enable Metrics/ParameterLists

      def blank?(value)
        value.nil? || value.to_s.empty?
      end
    end
  end
end
