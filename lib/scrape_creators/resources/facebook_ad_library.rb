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
      # Be careful that if an ad has multiple versions, you'll want to get the title
      # from the 'cards' object in the snapshot.
      #
      # @param id [String] The Facebook Ad ID (required)
      # @param get_transcript [Boolean, nil] Get the transcript of the ad. This is a new feature.
      # @param trim [Boolean, nil] Set to true for a trimmed down version of the response
      # @return [Hash] Response containing ad details including snapshot, targeting info, and metadata
      # @raise [ArgumentError] If id is not provided
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      # @raise [NotFoundError] If the ad is not found
      #
      # @example Get ad details
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.facebook_ad_library.ad(id: "702369045530963")
      #   puts result[:page_name]  # => "Porto Montenegro"
      #   puts result[:snapshot][:body]  # => Ad body text
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
      def ad(id:, get_transcript: nil, trim: nil)
        validate_ad_params!(id)

        params = build_ad_params(id, get_transcript, trim)
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

      private

      def validate_ad_params!(id)
        raise ArgumentError, "id is required" if blank?(id)
      end

      def validate_search_params!(query)
        raise ArgumentError, "query is required" if blank?(query)
      end

      def build_ad_params(id, get_transcript, trim)
        params = { id: id }
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

      def blank?(value)
        value.nil? || value.to_s.empty?
      end
    end
  end
end
