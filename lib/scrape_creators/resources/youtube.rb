# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # YouTube API resource
    #
    # Provides methods to interact with YouTube endpoints for scraping public channel data,
    # videos, shorts, comments, and more.
    #
    # @see https://docs.scrapecreators.com/v1/youtube YouTube API Documentation
    class Youtube < Resource
      # Get YouTube channel details
      #
      # Retrieves comprehensive channel information including stats and metadata.
      # You must provide at least one of: channel_id, handle, or url.
      #
      # @param channel_id [String, nil] YouTube channel ID (e.g., "UC-lHJZR3Gqxm24_Vd_AJ5Yw")
      # @param handle [String, nil] YouTube handle/username (e.g., "pewdiepie" or "@pewdiepie")
      # @param url [String, nil] YouTube channel URL
      # @return [Hash] Channel data including metadata, stats, and subscriber count
      # @raise [ArgumentError] If no identifier (channel_id, handle, or url) is provided
      # @raise [BadRequestError] If the parameters are invalid
      # @raise [NotFoundError] If the channel is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a YouTube channel by handle
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   channel = client.youtube.channel(handle: "ishowspeed")
      #   puts channel[:title]            # => "IShowSpeed"
      #   puts channel[:subscriber_count] # => 33500000
      #
      # @example Get a YouTube channel by channel ID
      #   channel = client.youtube.channel(channel_id: "UC-lHJZR3Gqxm24_Vd_AJ5Yw")
      #   puts channel[:title]            # => "PewDiePie"
      #
      # @example Get a YouTube channel by URL
      #   channel = client.youtube.channel(url: "https://www.youtube.com/@MrBeast")
      #   puts channel[:title]            # => "MrBeast"
      #
      # @example Response structure
      #   {
      #     channel_id: "UCX6OQ3DkcsbYNE6H8uQQuVA",
      #     title: "MrBeast",
      #     description: "SUBSCRIBE FOR A COOKIE!",
      #     custom_url: "@MrBeast",
      #     published_at: "2012-02-20T00:43:50Z",
      #     thumbnails: {
      #       default: { url: "https://...", width: 88, height: 88 },
      #       medium: { url: "https://...", width: 240, height: 240 },
      #       high: { url: "https://...", width: 800, height: 800 }
      #     },
      #     country: "US",
      #     view_count: 62000000000,
      #     subscriber_count: 358000000,
      #     video_count: 850,
      #     banner_external_url: "https://...",
      #     keywords: ["MrBeast", "Beast", ...],
      #     is_family_safe: true
      #   }
      def channel(channel_id: nil, handle: nil, url: nil)
        if channel_id.nil? && handle.nil? && url.nil?
          raise ArgumentError, "At least one of channel_id, handle, or url is required"
        end

        params = {}
        params[:channelId] = channel_id if channel_id
        params[:handle] = handle if handle
        params[:url] = url if url

        get("/v1/youtube/channel", params)
      end
    end
  end
end
