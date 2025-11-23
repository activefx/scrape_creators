# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Google Ad Library API resource
    #
    # Provides methods to interact with Google Ad Transparency endpoints for retrieving
    # company ads, ad details, and searching advertisers.
    #
    # @see https://docs.scrapecreators.com/v1/google-ad-library Google Ad Library API Documentation
    class GoogleAdLibrary < Resource
      # Get the ads for a company from Google Ad Transparency
      #
      # Retrieves public ads for a company based on domain or advertiser ID.
      # Note: This only gets public ads. Some ads require login and are not accessible.
      #
      # Starting November 10th 2025, you will need to add get_ad_details=true to get
      # the ad details (costs 25 credits). Without it, only advertiserId and creativeId
      # from each ad will be returned (costs 1 credit).
      #
      # @param domain [String, nil] The domain of the company (e.g., "foreplay.co")
      # @param advertiser_id [String, nil] The advertiser ID of the company
      # @param topic [String, nil] The topic to search for ("all" or "political").
      #   If "political", you must also pass a region.
      # @param region [String, nil] The region to search for (e.g., "US", "AU").
      #   Defaults to anywhere.
      # @param start_date [String, nil] Start date to search for (format: YYYY-MM-DD)
      # @param end_date [String, nil] End date to search for (format: YYYY-MM-DD)
      # @param get_ad_details [Boolean, nil] Set to true to get ad details (costs 25 credits)
      # @param cursor [String, nil] Cursor to paginate through results
      # @return [Hash] Response containing success status, credits remaining, ads array, and cursor
      # @raise [ArgumentError] If neither domain nor advertiser_id is provided
      # @raise [ArgumentError] If topic is "political" but region is not provided
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get ads by domain
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.google_ad_library.company_ads(domain: "foreplay.co")
      #   puts result[:ads].first[:advertiser_name]  # => "Foreplay Ventures Inc"
      #
      # @example Get ads by advertiser ID
      #   result = client.google_ad_library.company_ads(advertiser_id: "AR09628680369637163009")
      #
      # @example Get ads with full details
      #   result = client.google_ad_library.company_ads(
      #     domain: "foreplay.co",
      #     get_ad_details: true
      #   )
      #
      # @example Get political ads for a specific region
      #   result = client.google_ad_library.company_ads(
      #     domain: "example.com",
      #     topic: "political",
      #     region: "US"
      #   )
      #
      # @example Paginate through results
      #   first_page = client.google_ad_library.company_ads(domain: "foreplay.co")
      #   next_page = client.google_ad_library.company_ads(
      #     domain: "foreplay.co",
      #     cursor: first_page[:cursor]
      #   )
      #
      # @example Response structure
      #   {
      #     success: true,
      #     credits_remaining: 9926561,
      #     ads: [
      #       {
      #         advertiser_id: "AR09628680369637163009",
      #         creative_id: "CR15036700036807262209",
      #         format: "text",
      #         ad_url: "https://adstransparency.google.com/advertiser/.../creative/...",
      #         advertiser_name: "Foreplay Ventures Inc",
      #         domain: "foreplay.co",
      #         image_url: nil,
      #         first_shown: "2024-08-02T12:33:35.000Z",
      #         last_shown: "2025-11-10T19:31:13.000Z"
      #       }
      #     ],
      #     cursor: "CgoAP7zm82Y5sMRjEhBwPifBwIMxRttsqvUAAAAAGgn8..."
      #   }
      def company_ads(domain: nil, advertiser_id: nil, topic: nil, region: nil, **options)
        validate_company_ads_params!(domain, advertiser_id, topic, region)

        params = build_company_ads_params(domain, advertiser_id, topic, region, options)
        get("/v1/google/company/ads", params)
      end

      # Get the details for an ad from Google Ad Transparency
      #
      # Retrieves detailed information about a specific ad by its URL.
      # Note: OCR is used to extract text from the ad, so it might not be 100% accurate.
      #
      # @param url [String] The URL of the ad (required)
      # @return [Hash] Response containing ad details including advertiser info, format,
      #   impressions, regions, and variations
      # @raise [ArgumentError] If url is not provided
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      # @raise [NotFoundError] If the ad is not found
      #
      # @example Get ad details
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.google_ad_library.ad(url: "https://adstransparency.google.com/...")
      #   puts result[:format]  # => "text"
      #   puts result[:variations].first[:headline]  # => "Best Birthday Gifts"
      #
      # @example Response structure
      #   {
      #     success: true,
      #     advertiser_id: "AR01614014350098432001",
      #     creative_id: "CR07443539616616939521",
      #     first_shown: nil,
      #     last_shown: "2025-06-18T18:09:00.000Z",
      #     format: "text",
      #     overall_impressions: { min: nil, max: nil },
      #     creative_regions: [
      #       { region_code: "US", region_name: "United States" }
      #     ],
      #     region_stats: [
      #       {
      #         region_code: "US",
      #         region_name: "United States",
      #         first_shown: nil,
      #         last_shown: "2025-06-18T05:00:00.000Z",
      #         impressions: {},
      #         platform_impressions: []
      #       }
      #     ],
      #     variations: [
      #       {
      #         destination_url: "shop.lululemon.com/gifts-for-all",
      #         headline: "lululemonⓇ Official Site - Best Birthday Gifts",
      #         description: "Find The Perfect Gifts At lululemon...",
      #         all_text: "Sponsored Ω lululemon shop.lululemon.com...",
      #         image_url: "https://tpc.googlesyndication.com/..."
      #       }
      #     ]
      #   }
      def ad(url:)
        raise ArgumentError, "url is required" if blank?(url)

        get("/v1/google/ad", url: url)
      end

      private

      def validate_company_ads_params!(domain, advertiser_id, topic, region)
        raise ArgumentError, "domain or advertiser_id is required" if blank?(domain) && blank?(advertiser_id)

        return unless topic&.downcase == "political" && blank?(region)

        raise ArgumentError, "region is required when topic is 'political'"
      end

      def build_company_ads_params(domain, advertiser_id, topic, region, options)
        params = {}
        params[:domain] = domain unless blank?(domain)
        params[:advertiser_id] = advertiser_id unless blank?(advertiser_id)
        params[:topic] = topic unless topic.nil?
        params[:region] = region unless region.nil?
        params[:start_date] = options[:start_date] unless options[:start_date].nil?
        params[:end_date] = options[:end_date] unless options[:end_date].nil?
        params[:get_ad_details] = options[:get_ad_details] unless options[:get_ad_details].nil?
        params[:cursor] = options[:cursor] unless options[:cursor].nil?
        params
      end

      def blank?(value)
        value.nil? || value.to_s.empty?
      end
    end
  end
end
