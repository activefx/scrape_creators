# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Kick API resource
    #
    # Provides methods to interact with Kick endpoints for scraping public data
    # including clips and related content.
    #
    # @see https://docs.scrapecreators.com/v1/kick Kick API Documentation
    class Kick < Resource
      # Get a Kick clip
      #
      # Retrieves detailed information about a Kick clip including title, views,
      # duration, thumbnail, and associated category, creator, and channel data.
      #
      # @param url [String] Kick clip URL
      # @return [Hash] Clip data including clip info, category, creator, and channel
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the clip is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Kick clip
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.kick.clip("https://kick.com/xqc/clips/clip_01JGJHB6CEVFCQRYTVPM8DW892")
      #   puts result[:clip][:title]      # => "MonkaW"
      #   puts result[:clip][:views]      # => 11793
      #   puts result[:clip][:duration]   # => 50
      #
      # @example Access channel information
      #   result = client.kick.clip("https://kick.com/xqc/clips/clip_01JGJHB6CEVFCQRYTVPM8DW892")
      #   puts result[:clip][:channel][:username]  # => "xQc"
      #   puts result[:clip][:channel][:slug]      # => "xqc"
      #
      # @example Access creator information
      #   result = client.kick.clip("https://kick.com/xqc/clips/clip_01JGJHB6CEVFCQRYTVPM8DW892")
      #   puts result[:clip][:creator][:username]  # => "cskorm"
      #
      # @example Access category information
      #   result = client.kick.clip("https://kick.com/xqc/clips/clip_01JGJHB6CEVFCQRYTVPM8DW892")
      #   puts result[:clip][:category][:name]  # => "Just Chatting"
      #   puts result[:clip][:category][:slug]  # => "just-chatting"
      #
      # @example Response structure
      #   {
      #     clip: {
      #       id: "clip_01JGJHB6CEVFCQRYTVPM8DW892",
      #       livestream_id: "45013036",
      #       category_id: "15",
      #       channel_id: 668,
      #       user_id: 13035177,
      #       title: "MonkaW",
      #       clip_url: "https://clips.kick.com/clips/7a/.../playlist.m3u8",
      #       thumbnail_url: "https://clips.kick.com/clips/7a/.../thumbnail.webp",
      #       privacy: "CLIP_PRIVACY_PUBLIC",
      #       likes: 0,
      #       liked: false,
      #       views: 11793,
      #       duration: 50,
      #       started_at: "2025-01-02T03:34:51.825Z",
      #       created_at: "2025-01-02T03:37:13.559618Z",
      #       is_mature: false,
      #       video_url: "https://clips.kick.com/clips/7a/.../playlist.m3u8",
      #       view_count: 11793,
      #       likes_count: 0,
      #       vod: { id: "2ba60535-342e-4397-b16a-fb739ca96b21" },
      #       category: {
      #         id: 15,
      #         name: "Just Chatting",
      #         slug: "just-chatting",
      #         responsive: "https://files.kick.com/images/subcategories/15/...",
      #         banner: "https://files.kick.com/images/subcategories/15/...",
      #         parent_category: "irl"
      #       },
      #       creator: {
      #         id: 13035177,
      #         username: "cskorm",
      #         slug: "cskorm",
      #         profile_picture: nil
      #       },
      #       channel: {
      #         id: 668,
      #         username: "xQc",
      #         slug: "xqc",
      #         profile_picture: "https://files.kick.com/images/user/676/..."
      #       }
      #     }
      #   }
      def clip(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/kick/clip", url: url)
      end
    end
  end
end
