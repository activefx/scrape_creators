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

      # Get YouTube video or short transcript
      #
      # Retrieves the transcript/captions for a YouTube video or short if available.
      # Useful for extracting spoken content from videos. Returns detailed transcript
      # data with timing information and a plain text version.
      #
      # @param url [String] YouTube video or short URL (required)
      # @return [Hash] Transcript data including video metadata and transcript content
      # @raise [ArgumentError] If url is not provided
      # @raise [BadRequestError] If the parameters are invalid
      # @raise [NotFoundError] If the video is not found or has no transcript
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get video transcript
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   transcript = client.youtube.video_transcript(
      #     url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
      #   )
      #   puts transcript[:language]              # => "English"
      #   puts transcript[:transcript_only_text]  # => "Full transcript as plain text..."
      #
      # @example Get short transcript
      #   transcript = client.youtube.video_transcript(
      #     url: "https://www.youtube.com/shorts/abc123"
      #   )
      #   puts transcript[:type]                  # => "short"
      #   puts transcript[:transcript].first[:text]
      #
      # @example Iterate through transcript segments
      #   transcript = client.youtube.video_transcript(url: "https://www.youtube.com/watch?v=abc123")
      #   transcript[:transcript].each do |segment|
      #     puts "#{segment[:start_time_text]}: #{segment[:text]}"
      #   end
      #
      # @example Response structure
      #   {
      #     video_id: "bjVIDXPP7Uk",
      #     type: "video",
      #     url: "https://www.youtube.com/watch?v=bjVIDXPP7Uk",
      #     transcript: [
      #       {
      #         text: "welcome back to the hell farm and the",
      #         start_ms: "160",
      #         end_ms: "1920",
      #         start_time_text: "0:00"
      #       },
      #       {
      #         text: "backyard trails we built these jumps two",
      #         start_ms: "1920",
      #         end_ms: "3919",
      #         start_time_text: "0:01"
      #       }
      #     ],
      #     transcript_only_text: "welcome back to the hell farm and the backyard trails...",
      #     language: "English"
      #   }
      def video_transcript(url:)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.strip.empty?

        get("/v1/youtube/video/transcript", { url: url })
      end

      # Get comments from a YouTube video
      #
      # Retrieves comments from a video with engagement metrics and author information.
      # Supports pagination with continuation tokens. Can only get approximately 1k top
      # comments and about 7k newest comments.
      #
      # @param url [String] YouTube video URL (required)
      # @param continuation_token [String, nil] Token from previous response for pagination
      # @param order [String, nil] Order of comments
      #   Options: "top" (most relevant/popular), "newest" (most recent)
      # @return [Hash] Comments data with array of comments and optional continuation token
      # @raise [ArgumentError] If url is not provided
      # @raise [BadRequestError] If the parameters are invalid
      # @raise [NotFoundError] If the video is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get top comments from a video
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.youtube.video_comments(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
      #   result[:comments].each do |comment|
      #     puts "#{comment[:author][:name]}: #{comment[:content]}"
      #   end
      #
      # @example Get newest comments
      #   result = client.youtube.video_comments(
      #     url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      #     order: "newest"
      #   )
      #
      # @example Paginate through comments
      #   result = client.youtube.video_comments(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
      #   while result[:continuation_token]
      #     result = client.youtube.video_comments(
      #       url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      #       continuation_token: result[:continuation_token]
      #     )
      #   end
      #
      # @example Response structure
      #   {
      #     comments: [
      #       {
      #         id: "UgwVfRopfS2F-WB3aF14AaABAg",
      #         content: "I love this video!",
      #         published_time_text: "9 days ago",
      #         published_time: "2025-01-23T23:14:02.948Z",
      #         reply_level: 0,
      #         author: {
      #           name: "@username",
      #           channel_id: "UC8JC3uSUmmXTCTKl-bgr1DA",
      #           is_verified: false,
      #           is_creator: false,
      #           avatar_url: "https://yt3.ggpht.com/...",
      #           channel_url: "https://youtube.com/@username"
      #         },
      #         engagement: {
      #           likes: 110,
      #           replies: 5
      #         }
      #       }
      #     ],
      #     continuation_token: "Eg0SCzVFV2F4bVd...."
      #   }
      def video_comments(url:, continuation_token: nil, order: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.strip.empty?

        params = { url: url }
        params[:continuationToken] = continuation_token if continuation_token
        params[:order] = order if order

        get("/v1/youtube/video/comments", params)
      end

      # Search YouTube for videos, channels, playlists, shorts, and lives
      #
      # Searches YouTube and returns matching content across various types.
      # Supports filtering by upload date, sorting, and pagination.
      #
      # @param query [String] Search query (required)
      # @param upload_date [String, nil] Filter by upload date
      #   Options: "last_hour", "today", "this_week", "this_month", "this_year"
      # @param sort_by [String, nil] Sort order
      #   Options: "relevance", "upload_date"
      # @param filter [String, nil] Filter by content type. Only works when not using
      #   upload_date or sort_by. Options: "shorts"
      # @param continuation_token [String, nil] Token from previous response for pagination
      # @param include_extras [Boolean, nil] Include like/comment count and description
      #   (slightly slower response)
      # @return [Hash] Search results including videos, channels, playlists, shorts, shelves,
      #   lives, and continuation_token
      # @raise [ArgumentError] If query is not provided
      # @raise [BadRequestError] If the parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Basic search
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.youtube.search(query: "running")
      #   results[:videos].each do |video|
      #     puts "#{video[:title]} - #{video[:view_count_text]}"
      #   end
      #
      # @example Search with upload date filter
      #   results = client.youtube.search(query: "news", upload_date: "today")
      #
      # @example Search with sorting
      #   results = client.youtube.search(query: "tutorial", sort_by: "upload_date")
      #
      # @example Search for shorts only
      #   results = client.youtube.search(query: "funny", filter: "shorts")
      #
      # @example Paginate through results
      #   results = client.youtube.search(query: "cooking")
      #   while results[:continuation_token]
      #     results = client.youtube.search(
      #       query: "cooking",
      #       continuation_token: results[:continuation_token]
      #     )
      #   end
      #
      # @example Include extra details
      #   results = client.youtube.search(query: "music", include_extras: true)
      #
      # @example Response structure
      #   {
      #     videos: [
      #       {
      #         type: "video",
      #         id: "BzSzwqb-OEE",
      #         url: "https://www.youtube.com/watch?v=BzSzwqb-OEE",
      #         title: "NF - RUNNING (Audio)",
      #         thumbnail: "https://i.ytimg.com/vi/BzSzwqb-OEE/hq720.jpg",
      #         channel: {
      #           id: "UCoRR6OLuIZ2-5VxtnQIaN2w",
      #           title: "NFrealmusic",
      #           handle: "channel/UCoRR6OLuIZ2-5VxtnQIaN2w",
      #           thumbnail: "https://yt3.ggpht.com/..."
      #         },
      #         view_count_text: "14,860,541 views",
      #         view_count_int: 14860541,
      #         published_time_text: "2 years ago",
      #         published_time: "2023-05-28T17:08:46.499Z",
      #         length_text: "4:14",
      #         length_seconds: 254,
      #         badges: []
      #       }
      #     ],
      #     channels: [],
      #     playlists: [],
      #     shorts: [
      #       {
      #         type: "short",
      #         id: "uMNvF-lSCHg",
      #         url: "https://www.youtube.com/watch?v=uMNvF-lSCHg",
      #         title: "LONG RUN ROUTINE #run #runvlog #runner #shorts #morning",
      #         thumbnail: "https://i.ytimg.com/vi/uMNvF-lSCHg/hq720.jpg",
      #         channel: { id: "...", title: "...", handle: "...", thumbnail: "..." },
      #         view_count_text: "462,705 views",
      #         view_count_int: 462705,
      #         published_time_text: "10 months ago",
      #         published_time: "2024-07-28T17:08:46.498Z",
      #         length_text: "0:44",
      #         length_seconds: 44,
      #         badges: []
      #       }
      #     ],
      #     shelves: [
      #       {
      #         type: "shelf",
      #         title: "Shorts",
      #         items: [{ type: "short", id: "...", ... }]
      #       }
      #     ],
      #     lives: [],
      #     continuation_token: "EooDEg..."
      #   }
      def search(query:, upload_date: nil, sort_by: nil, filter: nil, continuation_token: nil, include_extras: nil)
        raise ArgumentError, "query is required" if query.nil? || query.to_s.strip.empty?

        params = { query: query }
        params[:uploadDate] = upload_date if upload_date
        params[:sortBy] = sort_by if sort_by
        params[:filter] = filter if filter
        params[:continuationToken] = continuation_token if continuation_token
        params[:includeExtras] = include_extras unless include_extras.nil?

        get("/v1/youtube/search", params)
      end

      # Search YouTube by hashtag
      #
      # Searches YouTube for videos associated with a specific hashtag.
      # Returns matching videos with optional filtering for shorts only.
      #
      # @param hashtag [String] Hashtag to search for (required)
      # @param continuation_token [String, nil] Token from previous response for pagination
      # @param type [String, nil] Filter content type
      #   Options: "all" (default), "shorts"
      # @return [Hash] Search results including videos array and continuation_token
      # @raise [ArgumentError] If hashtag is not provided
      # @raise [BadRequestError] If the parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Basic hashtag search
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.youtube.search_hashtag(hashtag: "funny")
      #   results[:videos].each do |video|
      #     puts "#{video[:title]} - #{video[:view_count_text]}"
      #   end
      #
      # @example Search for shorts only
      #   results = client.youtube.search_hashtag(hashtag: "fails", type: "shorts")
      #   results[:videos].each do |video|
      #     puts video[:title]
      #   end
      #
      # @example Paginate through results
      #   results = client.youtube.search_hashtag(hashtag: "cooking")
      #   while results[:continuation_token]
      #     results = client.youtube.search_hashtag(
      #       hashtag: "cooking",
      #       continuation_token: results[:continuation_token]
      #     )
      #   end
      #
      # @example Response structure
      #   {
      #     videos: [
      #       {
      #         type: "video",
      #         id: "jXMISgQq9MM",
      #         url: "https://www.youtube.com/watch?v=jXMISgQq9MM",
      #         title: "Epic fails 🤣🤣🤣 #shorts #funny #fails",
      #         description: "",
      #         thumbnail: "https://i.ytimg.com/vi/jXMISgQq9MM/hqdefault.jpg?...",
      #         channel: {
      #           id: "UCvUzWu1Whyw1FWuLl9GOo_g",
      #           title: "ZZang Funny",
      #           thumbnail: "https://yt3.ggpht.com/..."
      #         },
      #         view_count_text: "22,668,056 views",
      #         view_count_int: 22668056,
      #         published_time_text: "4 weeks ago",
      #         published_time: "2025-01-04T23:12:42.919Z",
      #         length_text: "1:00",
      #         length_seconds: 60,
      #         badges: []
      #       }
      #     ],
      #     continuation_token: "4qmFsgLtBRIJRkVoYX...."
      #   }
      def search_hashtag(hashtag:, continuation_token: nil, type: nil)
        raise ArgumentError, "hashtag is required" if hashtag.nil? || hashtag.to_s.strip.empty?

        params = { hashtag: hashtag }
        params[:continuationToken] = continuation_token if continuation_token
        params[:type] = type if type

        get("/v1/youtube/search/hashtag", params)
      end

      # Get trending YouTube shorts
      #
      # Retrieves approximately 48 currently trending shorts on YouTube.
      # No parameters required - returns the current trending shorts.
      #
      # @return [Hash] Trending shorts data including success status and array of shorts
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get trending shorts
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.youtube.trending_shorts
      #   result[:shorts].each do |short|
      #     puts "#{short[:title]} - #{short[:view_count_text]}"
      #   end
      #
      # @example Access short details
      #   result = client.youtube.trending_shorts
      #   short = result[:shorts].first
      #   puts short[:channel][:title]     # => "Dame Universe"
      #   puts short[:view_count_int]      # => 13798774
      #   puts short[:duration_formatted]  # => "00:00:19"
      #
      # @example Response structure
      #   {
      #     success: true,
      #     shorts: [
      #       {
      #         id: "ou0nl5ET0HA",
      #         thumbnail: "https://img.youtube.com/vi/ou0nl5ET0HA/maxresdefault.jpg",
      #         url: "https://www.youtube.com/watch?v=ou0nl5ET0HA",
      #         title: "That hooper who says their just shoes",
      #         description: nil,
      #         comment_count_text: "168",
      #         comment_count_int: 168,
      #         like_count_text: "151957",
      #         like_count_int: 151957,
      #         view_count_text: "13,798,774",
      #         view_count_int: 13798774,
      #         publish_date_text: "Aug 7, 2025",
      #         publish_date: "2025-08-07T13:00:22-07:00",
      #         channel: {
      #           id: "UC3iObCgKLKr9xquQw7fCang",
      #           url: "https://www.youtube.com/@dameuniverse",
      #           handle: "dameuniverse",
      #           title: "Dame Universe"
      #         },
      #         chapters: [],
      #         keywords: ["Kobe", "Sneaker heads", ...],
      #         duration_ms: 19000,
      #         duration_formatted: "00:00:19"
      #       }
      #     ]
      #   }
      def trending_shorts
        get("/v1/youtube/shorts/trending", {})
      end

      # Get videos from a YouTube playlist
      #
      # Retrieves videos from a YouTube playlist with detailed information including
      # video titles, thumbnails, duration, and channel information.
      #
      # @param playlist_id [String] YouTube playlist ID (required). In the YouTube URL
      #   it will be the 'list' parameter.
      # @return [Hash] Playlist data including title, owner, total videos, and videos array
      # @raise [ArgumentError] If playlist_id is not provided
      # @raise [BadRequestError] If the parameters are invalid
      # @raise [NotFoundError] If the playlist is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get videos from a playlist
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.youtube.playlist(playlist_id: "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf")
      #   puts result[:title]         # => "Songs with Lyrics 2025 - New Songs 2025"
      #   puts result[:totalVideos]   # => 98
      #   result[:videos].each do |video|
      #     puts "#{video[:title]} - #{video[:lengthText]}"
      #   end
      #
      # @example Extract playlist ID from URL
      #   # Given URL: https://www.youtube.com/playlist?list=PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf
      #   # The playlist_id is: PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf
      #   result = client.youtube.playlist(playlist_id: "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf")
      #
      # @example Access playlist owner information
      #   result = client.youtube.playlist(playlist_id: "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf")
      #   owner = result[:owner]
      #   puts owner[:name]           # => "Lovely Tunes"
      #   puts owner[:handle]         # => "lovelytunes7622"
      #   puts owner[:url]            # => "https://www.youtube.com/@lovelytunes7622"
      #
      # @example Response structure
      #   {
      #     success: true,
      #     credits_remaining: 99404,
      #     title: "Songs with Lyrics 2025 - New Songs 2025 - Music 2025 New Songs",
      #     owner: {
      #       id: "UC0-wiBH12UgtWqLjo-EvpOw",
      #       name: "Lovely Tunes",
      #       url: "https://www.youtube.com/@lovelytunes7622",
      #       handle: "lovelytunes7622"
      #     },
      #     totalVideos: 98,
      #     videos: [
      #       {
      #         id: "AdBzzpq3xV4",
      #         title: "Lady Gaga, Bruno Mars - Die With A Smile",
      #         thumbnail: "https://i.ytimg.com/vi/AdBzzpq3xV4/hqdefault.jpg?...",
      #         url: "https://www.youtube.com/watch?v=AdBzzpq3xV4",
      #         lengthText: "4:15",
      #         lengthSeconds: 255,
      #         channel: {
      #           title: "LatinHype",
      #           url: "https://www.youtube.com/@LatinHype."
      #         }
      #       }
      #     ]
      #   }
      def playlist(playlist_id:)
        raise ArgumentError, "playlist_id is required" if playlist_id.nil? || playlist_id.to_s.strip.empty?

        get("/v1/youtube/playlist", { playlist_id: playlist_id })
      end
    end
  end
end
