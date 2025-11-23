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

      private

      def validate_ad_params!(id)
        raise ArgumentError, "id is required" if blank?(id)
      end

      def build_ad_params(id, get_transcript, trim)
        params = { id: id }
        params[:get_transcript] = get_transcript unless get_transcript.nil?
        params[:trim] = trim unless trim.nil?
        params
      end

      def blank?(value)
        value.nil? || value.to_s.empty?
      end
    end
  end
end
