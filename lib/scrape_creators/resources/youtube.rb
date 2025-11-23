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

      # Get all videos from a YouTube channel
      #
      # Retrieves videos from a channel with detailed information including view counts,
      # thumbnails, and duration. Supports pagination with continuation tokens.
      # You must provide at least one of: channel_id or handle.
      #
      # @param channel_id [String, nil] YouTube channel ID (e.g., "UCX6OQ3DkcsbYNE6H8uQQuVA")
      # @param handle [String, nil] YouTube handle/username (e.g., "mrbeast" or "@mrbeast")
      # @param sort [String, nil] Sort order - "latest" or "popular"
      # @param continuation_token [String, nil] Token from previous response to get more videos
      # @param include_extras [Boolean, nil] Include like/comment count and description (slower)
      # @return [Hash] Videos data with array of videos and optional continuation token
      # @raise [ArgumentError] If no identifier (channel_id or handle) is provided
      # @raise [BadRequestError] If the parameters are invalid
      # @raise [NotFoundError] If the channel is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get videos from a channel by handle
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.youtube.channel_videos(handle: "mrbeast")
      #   result[:videos].each do |video|
      #     puts "#{video[:title]} - #{video[:view_count_text]}"
      #   end
      #
      # @example Get popular videos sorted
      #   result = client.youtube.channel_videos(handle: "mrbeast", sort: "popular")
      #
      # @example Paginate through videos
      #   result = client.youtube.channel_videos(handle: "mrbeast")
      #   while result[:continuation_token]
      #     result = client.youtube.channel_videos(
      #       handle: "mrbeast",
      #       continuation_token: result[:continuation_token]
      #     )
      #   end
      #
      # @example Include extra details (likes, comments, description)
      #   result = client.youtube.channel_videos(handle: "mrbeast", include_extras: true)
      #
      # @example Response structure
      #   {
      #     videos: [
      #       {
      #         type: "video",
      #         id: "5EWaxmWgQMI",
      #         url: "https://www.youtube.com/watch?v=5EWaxmWgQMI",
      #         title: "Video Title",
      #         description: "Video description...",
      #         thumbnail: "https://i.ytimg.com/vi/5EWaxmWgQMI/hqdefault.jpg",
      #         channel: { title: "", thumbnail: nil },
      #         view_count_text: "110,447 views",
      #         view_count_int: 110447,
      #         published_time_text: "9 days ago",
      #         published_time: "2025-01-23T22:48:53.914Z",
      #         length_text: "37:25",
      #         length_seconds: 2245,
      #         badges: []
      #       }
      #     ],
      #     continuation_token: "4qmFsgLlFhIYW..."
      #   }
      def channel_videos(channel_id: nil, handle: nil, sort: nil, continuation_token: nil, include_extras: nil)
        raise ArgumentError, "At least one of channel_id or handle is required" if channel_id.nil? && handle.nil?

        params = {}
        params[:channelId] = channel_id if channel_id
        params[:handle] = handle if handle
        params[:sort] = sort if sort
        params[:continuationToken] = continuation_token if continuation_token
        params[:includeExtras] = include_extras unless include_extras.nil?

        get("/v1/youtube/channel-videos", params)
      end

      # Get shorts from a YouTube channel
      #
      # Retrieves shorts from a channel with engagement metrics. For more details about
      # a short like description, publish date, etc., use the Video/Short Details endpoint.
      # You must provide at least one of: channel_id or handle.
      #
      # @param channel_id [String, nil] YouTube channel ID (e.g., "UCX6OQ3DkcsbYNE6H8uQQuVA")
      # @param handle [String, nil] YouTube handle/username (e.g., "mrbeast" or "@mrbeast")
      # @param sort [String, nil] Sort order - "newest" or "popular"
      # @param continuation_token [String, nil] Token from previous response to get more shorts
      # @return [Hash] Shorts data with array of shorts and optional continuation token
      # @raise [ArgumentError] If no identifier (channel_id or handle) is provided
      # @raise [BadRequestError] If the parameters are invalid
      # @raise [NotFoundError] If the channel is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get shorts from a channel by handle
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.youtube.channel_shorts(handle: "mrbeast")
      #   result[:shorts].each do |short|
      #     puts "#{short[:title]} - #{short[:view_count_text]}"
      #   end
      #
      # @example Get popular shorts sorted
      #   result = client.youtube.channel_shorts(handle: "mrbeast", sort: "popular")
      #
      # @example Get newest shorts
      #   result = client.youtube.channel_shorts(handle: "mrbeast", sort: "newest")
      #
      # @example Paginate through shorts
      #   result = client.youtube.channel_shorts(handle: "mrbeast")
      #   while result[:continuation_token]
      #     result = client.youtube.channel_shorts(
      #       handle: "mrbeast",
      #       continuation_token: result[:continuation_token]
      #     )
      #   end
      #
      # @example Response structure
      #   {
      #     success: true,
      #     credits_remaining: 9998708,
      #     shorts: [
      #       {
      #         type: "short",
      #         id: "Rdr8357wIRA",
      #         url: "https://www.youtube.com/watch?v=Rdr8357wIRA",
      #         title: "My app failed, then I changed one thing, and made $80K",
      #         view_count_text: "8,035",
      #         view_count_int: 8035,
      #         description: "Praneeth quit his $250K/year job...",
      #         comment_count_text: "12",
      #         comment_count_int: 12,
      #         like_count_int: 253,
      #         like_count_text: "253"
      #       }
      #     ],
      #     continuation_token: "4qmFsgK9DBIYVUNoaHc2RGxLS1..."
      #   }
      def channel_shorts(channel_id: nil, handle: nil, sort: nil, continuation_token: nil)
        raise ArgumentError, "At least one of channel_id or handle is required" if channel_id.nil? && handle.nil?

        params = {}
        params[:channelId] = channel_id if channel_id
        params[:handle] = handle if handle
        params[:sort] = sort if sort
        params[:continuationToken] = continuation_token if continuation_token

        get("/v1/youtube/channel/shorts", params)
      end

      # Get latest shorts from a YouTube channel (auto-pagination convenience endpoint)
      #
      # Convenience endpoint that handles pagination automatically to retrieve a specified
      # number of shorts. This costs more credits as it uses the Channel Shorts endpoint
      # internally. For more details about each short (description, publish date, etc.),
      # use the Video/Short Details endpoint.
      # You must provide at least one of: channel_id or handle.
      #
      # @param channel_id [String, nil] YouTube channel ID (e.g., "UCX6OQ3DkcsbYNE6H8uQQuVA")
      # @param handle [String, nil] YouTube handle/username (e.g., "mrbeast" or "@mrbeast")
      # @param amount [Integer] Number of shorts to return (required)
      # @return [Array<Hash>] Array of shorts with basic information
      # @raise [ArgumentError] If no identifier (channel_id or handle) is provided
      # @raise [ArgumentError] If amount is not provided
      # @raise [BadRequestError] If the parameters are invalid
      # @raise [NotFoundError] If the channel is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get 10 latest shorts from a channel by handle
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   shorts = client.youtube.channel_shorts_simple(handle: "mrbeast", amount: 10)
      #   shorts.each do |short|
      #     puts "#{short[:title]} - #{short[:view_count_text]}"
      #   end
      #
      # @example Get 5 shorts by channel ID
      #   shorts = client.youtube.channel_shorts_simple(
      #     channel_id: "UCX6OQ3DkcsbYNE6H8uQQuVA",
      #     amount: 5
      #   )
      #
      # @example Response structure (returns array directly)
      #   [
      #     {
      #       type: "short",
      #       id: "01D3CgMZ29I",
      #       url: "https://www.youtube.com/watch?v=01D3CgMZ29I",
      #       title: "WHAT A MATCH",
      #       thumbnail: "https://i.ytimg.com/vi/01D3CgMZ29I/oardefault.jpg?...",
      #       view_count_text: "13K",
      #       view_count_int: 13000
      #     },
      #     {
      #       type: "short",
      #       id: "zCgeCq9hKhY",
      #       url: "https://www.youtube.com/watch?v=zCgeCq9hKhY",
      #       title: "THE FINAL BOSS ALWAYS HAS A PLAN",
      #       thumbnail: "https://i.ytimg.com/vi/zCgeCq9hKhY/oardefault.jpg?...",
      #       view_count_text: "37K",
      #       view_count_int: 37000
      #     }
      #   ]
      def channel_shorts_simple(amount:, channel_id: nil, handle: nil)
        raise ArgumentError, "At least one of channel_id or handle is required" if channel_id.nil? && handle.nil?

        params = { amount: amount }
        params[:channelId] = channel_id if channel_id
        params[:handle] = handle if handle

        get("/v1/youtube/channel/shorts/simple", params)
      end

      # Get YouTube video or short details
      #
      # Retrieves complete information about a video or short including optional transcript.
      # Provides detailed metadata, engagement stats, channel info, watch next recommendations,
      # and optionally the full transcript.
      #
      # @param url [String] YouTube video or short URL (required)
      # @param get_transcript [Boolean, nil] Whether to include transcript in response
      # @return [Hash] Video data including metadata, stats, channel info, and optional transcript
      # @raise [ArgumentError] If url is not provided
      # @raise [BadRequestError] If the parameters are invalid
      # @raise [NotFoundError] If the video is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get video details without transcript
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   video = client.youtube.video(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
      #   puts video[:title]          # => "Rick Astley - Never Gonna Give You Up"
      #   puts video[:view_count_int] # => 1500000000
      #
      # @example Get video details with transcript
      #   video = client.youtube.video(
      #     url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      #     get_transcript: true
      #   )
      #   puts video[:transcript_only_text] # => "We're no strangers to love..."
      #
      # @example Get short details
      #   short = client.youtube.video(url: "https://www.youtube.com/shorts/abc123")
      #   puts short[:type]           # => "short"
      #   puts short[:duration_formatted] # => "00:00:45"
      #
      # @example Response structure
      #   {
      #     id: "Y2Ah_DFr8cw",
      #     thumbnail: "https://img.youtube.com/vi/G6VTenw0S7o/maxresdefault.jpg",
      #     type: "video",
      #     title: "Video Title",
      #     description: "Video description...",
      #     comment_count_text: "347",
      #     comment_count_int: 347,
      #     like_count_text: "3.8K",
      #     like_count_int: 3800,
      #     view_count_text: "358,277",
      #     view_count_int: 358277,
      #     publish_date_text: "Feb 22, 2019",
      #     publish_date: "2019-02-22T00:00:00.000Z",
      #     channel: {
      #       id: "UCWH3hing1Qb4LnkRfQdxsxQ",
      #       url: "https://www.youtube.com/@channelhandle",
      #       handle: "channelhandle",
      #       title: "Channel Name"
      #     },
      #     duration_ms: 1670000,
      #     duration_formatted: "00:27:50",
      #     watch_next_videos: [
      #       {
      #         id: "fRfkvQwf9Po",
      #         title: "Related Video Title",
      #         thumbnail: "https://i.ytimg.com/vi/fRfkvQwf9Po/hqdefault.jpg",
      #         channel: { title: "Channel", url: "...", handle: "...", id: "..." },
      #         publish_date_text: "5 years ago",
      #         view_count_text: "7,913,223 views",
      #         view_count_int: 7913223,
      #         length_text: "19:13",
      #         video_url: "https://www.youtube.com/watch?v=fRfkvQwf9Po"
      #       }
      #     ],
      #     keywords: ["keyword1", "keyword2"],
      #     transcript: [
      #       { text: "transcript text", start_ms: "0", end_ms: "5759", start_time_text: "0:00" }
      #     ],
      #     transcript_only_text: "Full transcript as plain text..."
      #   }
      def video(url:, get_transcript: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.strip.empty?

        params = { url: url }
        params[:get_transcript] = get_transcript unless get_transcript.nil?

        get("/v1/youtube/video", params)
      end
    end
  end
end
