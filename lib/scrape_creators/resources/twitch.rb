# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Twitch API resource
    #
    # Provides methods to interact with Twitch endpoints for scraping public profile data
    # including videos, clips, and similar streamers.
    #
    # @see https://docs.scrapecreators.com/v1/twitch Twitch API Documentation
    class Twitch < Resource
      # Get a public Twitch profile
      #
      # Retrieves public profile information for a Twitch user including
      # display name, description, follower count, social links, videos, clips,
      # and similar streamers.
      #
      # @param handle [String] Twitch username/handle
      # @return [Hash] Profile data including user info, videos, clips, and similar streamers
      # @raise [ArgumentError] If the handle parameter is nil or empty
      # @raise [BadRequestError] If the handle parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Twitch profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   profile = client.twitch.profile("ninja")
      #   puts profile[:display_name]  # => "Ninja"
      #   puts profile[:followers]     # => 19235206
      #   puts profile[:description]   # => "Just want to make people happy..."
      #
      # @example Access social links
      #   profile = client.twitch.profile("ninja")
      #   puts profile[:instagram]  # => "https://www.instagram.com/ninja"
      #   puts profile[:x]          # => "https://x.com/ninja"
      #   puts profile[:tiktok]     # => "https://www.tiktok.com/@ninja"
      #
      # @example Access videos and clips
      #   profile = client.twitch.profile("ninja")
      #   profile[:all_videos].each { |video| puts video[:title] }
      #   profile[:featured_clips].each { |clip| puts clip[:clip_title] }
      #
      # @example Response structure
      #   {
      #     success: true,
      #     id: "19571641",
      #     handle: "ninja",
      #     display_name: "Ninja",
      #     description: "Just want to make people happy. Co-Founder @DrinkNutcase. ",
      #     followers: 19235206,
      #     instagram: "https://www.instagram.com/ninja",
      #     x: "https://x.com/ninja",
      #     tiktok: "https://www.tiktok.com/@ninja",
      #     bit: "http://bit.ly/SubscribeNinja",
      #     all_videos: [
      #       {
      #         id: "2534457664",
      #         title: "USE CODE NINJA...",
      #         length_seconds: 35910,
      #         view_count: 278659,
      #         published_at: "2025-08-08T13:05:39Z",
      #         game: { id: "33214", name: "Fortnite", display_name: "Fortnite" },
      #         owner: { display_name: "Ninja", login: "ninja" },
      #         ...
      #       }
      #     ],
      #     featured_clips: [
      #       {
      #         id: "3724988753",
      #         slug: "AthleticKindJayEleGiggle-BcNDJkcggMoP5HCa",
      #         clip_title: "andre the bus driver",
      #         clip_view_count: 1799,
      #         duration_seconds: 30,
      #         created_at: "2025-08-08T16:08:23Z",
      #         ...
      #       }
      #     ],
      #     similar_streamers: [
      #       {
      #         id: "964426424",
      #         display_name: "ninjasologames",
      #         login: "ninjasologames",
      #         ...
      #       }
      #     ]
      #   }
      def profile(handle)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        get("/v1/twitch/profile", handle: handle)
      end
    end
  end
end
