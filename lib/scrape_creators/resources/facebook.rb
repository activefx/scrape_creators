# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Facebook API resource
    #
    # Provides methods to interact with Facebook endpoints for scraping public profile data,
    # business information, and more.
    #
    # @see https://docs.scrapecreators.com/v1/facebook Facebook API Documentation
    class Facebook < Resource
      # Get public Facebook profile information
      #
      # Scrapes a public Facebook profile including business information, contact details,
      # photos, ratings, and social metrics.
      #
      # @param url [String] Facebook profile URL
      # @param get_business_hours [Boolean, nil] Whether to include business hours in the response
      # @return [Hash] Profile data including business info, photos, and social metrics
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Facebook profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   profile = client.facebook.profile("https://www.facebook.com/copperkettleyqr/")
      #   puts profile[:name]           # => "The Copper Kettle Restaurant"
      #   puts profile[:follower_count] # => 2900
      #
      # @example Get a Facebook profile with business hours
      #   profile = client.facebook.profile("https://www.facebook.com/copperkettleyqr/", get_business_hours: true)
      #   puts profile[:business_hours] # => [{ monday: { open: "11:00", close: "00:00", ... } }, ...]
      #
      # @example Response structure
      #   {
      #     success: true,
      #     credits_remaining: 9946894,
      #     ad_library: {
      #       ad_status: "This Page is currently running ads.",
      #       page_id: "851606664870954"
      #     },
      #     creation_date: "October 29, 2014",
      #     business_hours: [
      #       {
      #         monday: {
      #           open: "11:00",
      #           close: "00:00",
      #           full_text: "11:00 - 00:00"
      #         }
      #       }
      #     ],
      #     id: "100064027242849",
      #     name: "The Copper Kettle Restaurant",
      #     url: "https://www.facebook.com/copperkettleyqr/",
      #     gender: "NEUTER",
      #     cover_photo: {
      #       focus: { x: 0.5, y: 0.48327464788732 },
      #       photo: {
      #         id: "436705571807014",
      #         image: {
      #           uri: "https://...",
      #           width: 960,
      #           height: 641
      #         },
      #         url: "https://www.facebook.com/photo/?fbid=..."
      #       }
      #     },
      #     is_business_page_active: false,
      #     profile_photo: {
      #       url: "https://www.facebook.com/photo/?fbid=...",
      #       viewer_image: { height: 320, width: 320 },
      #       id: "436705568473681"
      #     },
      #     profile_pic_large: "https://...",
      #     profile_pic_medium: "https://...",
      #     profile_pic_small: "https://...",
      #     page_intro: "Longstanding local restaurant. Mediterranean specialties...",
      #     category: "Pizza place",
      #     address: "1953 Scarth Street, Regina, SK, Canada, Saskatchewan",
      #     email: "copperkettle.events@gmail.com",
      #     links: ["https://www.instagram.com/copperkettleyqr"],
      #     phone: "+1 306-525-3545",
      #     website: "http://www.thecopperkettle.online/",
      #     services: "Outdoor seating",
      #     price_range: "££",
      #     rating: "94% recommend (205 reviews)",
      #     rating_count: nil,
      #     like_count: 2660,
      #     follower_count: 2900
      #   }
      def profile(url, get_business_hours: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:get_business_hours] = get_business_hours unless get_business_hours.nil?

        get("/v1/facebook/profile", params)
      end
    end
  end
end
