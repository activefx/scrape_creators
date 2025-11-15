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
    end
  end
end
