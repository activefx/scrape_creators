# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # TikTok API resource
    #
    # Provides methods to interact with TikTok endpoints for scraping public profile data,
    # videos, comments, search, and more.
    #
    # @see https://docs.scrapecreators.com/v1/tiktok TikTok API Documentation
    class Tiktok < Resource
      # Get a TikTok user profile
      #
      # Scrapes a public TikTok profile including user information, statistics, and metadata.
      #
      # @param handle [String] TikTok handle (username)
      # @return [Hash] Profile data including user info, stats, and item list
      # @raise [BadRequestError] If the handle parameter is missing or invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a TikTok profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   profile = client.tiktok.profile("stoolpresidente")
      #   puts profile[:user][:nickname]  # => "Dave Portnoy"
      #   puts profile[:stats][:followerCount]  # => 4100000
      #
      # @example Response structure
      #   {
      #     user: {
      #       id: "6659752019493208069",
      #       uniqueId: "stoolpresidente",
      #       nickname: "Dave Portnoy",
      #       avatarLarger: "https://...",
      #       signature: "El Presidente/Barstool Sports Founder.",
      #       verified: true,
      #       bioLink: { link: "https://...", risk: 0 },
      #       privateAccount: false,
      #       ...
      #     },
      #     stats: {
      #       followerCount: 4100000,
      #       followingCount: 74,
      #       heart: 190400000,
      #       videoCount: 2017,
      #       ...
      #     },
      #     itemList: []
      #   }
      def profile(handle)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        get("/v1/tiktok/profile", { handle: handle })
      end

      # Get audience demographics for a TikTok user
      #
      # Returns the audience demographics including country distribution for a TikTok user.
      # Currently only provides audience location data by country.
      #
      # @note This endpoint costs 26 credits per request
      #
      # @param handle [String] TikTok handle (username)
      # @return [Hash] Audience demographics data with country distribution
      # @raise [BadRequestError] If the handle parameter is missing or invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get audience demographics
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   audience = client.tiktok.audience("handle")
      #   puts audience[:success]  # => true
      #   puts audience[:audienceLocations].first[:country]  # => "Mexico"
      #   puts audience[:audienceLocations].first[:percentage]  # => "15.96%"
      #
      # @example Response structure
      #   {
      #     success: true,
      #     audienceLocations: [
      #       {
      #         country: "Mexico",
      #         countryCode: "MX",
      #         count: 83,
      #         percentage: "15.96%"
      #       },
      #       {
      #         country: "United States",
      #         countryCode: "US",
      #         count: 34,
      #         percentage: "6.54%"
      #       },
      #       ...
      #     ]
      #   }
      def audience(handle)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        get("/v1/tiktok/user/audience", { handle: handle })
      end
    end
  end
end
