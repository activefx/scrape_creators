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

      # Get a Twitch clip
      #
      # Retrieves detailed information about a Twitch clip including video URLs,
      # broadcaster info, curator info, view count, and related clips from the broadcaster.
      #
      # @param url [String] Twitch clip URL (e.g., "https://clips.twitch.tv/CloudySavageMarjoramRuleFive--ErzsYbE7UWvgCMQ")
      # @return [Array<Hash>] Array of response data containing clip info and related clips
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the clip is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Twitch clip
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.twitch.clip("https://clips.twitch.tv/CloudySavageMarjoramRuleFive--ErzsYbE7UWvgCMQ")
      #   clip = result.first[:data][:clip]
      #   puts clip[:title]           # => "un grande el mesero"
      #   puts clip[:view_count]      # => 52441
      #   puts clip[:duration_seconds] # => 27
      #
      # @example Access video qualities
      #   result = client.twitch.clip("https://clips.twitch.tv/...")
      #   clip = result.first[:data][:clip]
      #   clip[:video_qualities].each do |quality|
      #     puts quality[:source_url]
      #   end
      #
      # @example Access broadcaster information
      #   result = client.twitch.clip("https://clips.twitch.tv/...")
      #   clip = result.first[:data][:clip]
      #   puts clip[:broadcaster][:display_name]  # => "Staryuuki"
      #   puts clip[:broadcaster][:followers][:total_count]  # => 3450065
      #
      # @example Access related clips from the broadcaster
      #   result = client.twitch.clip("https://clips.twitch.tv/...")
      #   user_clips = result[1][:data][:user][:clips][:edges]
      #   user_clips.each do |edge|
      #     puts edge[:node][:title]
      #     puts edge[:node][:view_count]
      #   end
      def clip(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/twitch/clip", url: url)
      end
    end
  end
end
