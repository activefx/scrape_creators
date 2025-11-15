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

      # Get TikTok profile videos with manual cursor pagination
      #
      # Returns a list of videos from a TikTok user's profile with manual cursor-based pagination.
      # This is the v3 endpoint that provides more control over pagination using cursors.
      #
      # @param handle [String] TikTok handle (username)
      # @param sort_by [String, nil] Sort order - "oldest" or "newest" (default: "newest")
      # @param max_cursor [String, nil] Cursor for pagination to get next page of results
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Videos data with items array, cursor information, and hasMore flag
      # @raise [BadRequestError] If the handle parameter is missing or invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get most recent videos
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   videos = client.tiktok.profile_videos("stoolpresidente")
      #   puts videos[:itemList].first[:desc]  # Video description
      #   puts videos[:hasMore]  # => true/false
      #
      # @example Get oldest videos first
      #   videos = client.tiktok.profile_videos("stoolpresidente", sort_by: "oldest")
      #
      # @example Paginate through results
      #   page1 = client.tiktok.profile_videos("handle")
      #   page2 = client.tiktok.profile_videos("handle", max_cursor: page1[:maxCursor])
      #
      # @example Response structure
      #   {
      #     itemList: [
      #       {
      #         id: "7445883744370625822",
      #         desc: "Video description",
      #         createTime: 1234567890,
      #         video: { ... },
      #         stats: { diggCount: 123, shareCount: 45, ... }
      #       }
      #     ],
      #     cursor: "123456",
      #     maxCursor: "789012",
      #     hasMore: true
      #   }
      def profile_videos(handle, sort_by: nil, max_cursor: nil, trim: nil)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        params = { handle: handle }
        params[:sortBy] = sort_by if sort_by
        params[:maxCursor] = max_cursor if max_cursor
        params[:trim] = trim unless trim.nil?

        get("/v3/tiktok/profile/videos", params)
      end

      # Get TikTok profile videos with automatic pagination
      #
      # Returns a list of videos from a TikTok user's profile with automatic pagination.
      # This endpoint automatically handles pagination and can return a specified amount of videos.
      # Requires either handle or user_id parameter.
      #
      # @param handle [String, nil] TikTok handle (username)
      # @param user_id [String, nil] TikTok user ID
      # @param sort_by [String, nil] Sort order - "oldest" or "newest" (default: "newest")
      # @param amount [Integer, nil] Number of videos to return (automatically paginates)
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Videos data with items array
      # @raise [BadRequestError] If both handle and user_id are missing, or if parameters are invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get videos by handle
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   videos = client.tiktok.profile_videos_paginated(handle: "stoolpresidente")
      #
      # @example Get videos by user ID
      #   videos = client.tiktok.profile_videos_paginated(user_id: "6659752019493208069")
      #
      # @example Get specific amount of oldest videos
      #   videos = client.tiktok.profile_videos_paginated(
      #     handle: "stoolpresidente",
      #     sort_by: "oldest",
      #     amount: 50
      #   )
      #
      # @example Response structure
      #   {
      #     itemList: [
      #       {
      #         id: "7445883744370625822",
      #         desc: "Video description",
      #         createTime: 1234567890,
      #         video: { ... },
      #         stats: { diggCount: 123, shareCount: 45, ... }
      #       }
      #     ]
      #   }
      def profile_videos_paginated(handle: nil, user_id: nil, sort_by: nil, amount: nil, trim: nil)
        raise ArgumentError, "handle or user_id is required" if handle.nil? && user_id.nil?

        params = {}
        params[:handle] = handle if handle
        params[:userId] = user_id if user_id
        params[:sortBy] = sort_by if sort_by
        params[:amount] = amount if amount
        params[:trim] = trim unless trim.nil?

        get("/v3/tiktok/profile-videos", params)
      end

      # Get TikTok video information
      #
      # Returns detailed information about a specific TikTok video including metadata,
      # statistics, author information, and optionally the video transcript.
      #
      # @note This is the v2 endpoint with enhanced features
      #
      # @param url [String] TikTok video URL
      # @param get_transcript [Boolean, nil] Whether to include video transcript (default: false)
      # @param region [String, nil] Region code for content localization
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Video data including metadata, stats, author, and optional transcript
      # @raise [BadRequestError] If the url parameter is missing or invalid
      # @raise [NotFoundError] If the video is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get video information
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   video = client.tiktok.video("https://www.tiktok.com/@user/video/1234567890")
      #   puts video[:desc]  # Video description
      #   puts video[:stats][:playCount]  # View count
      #
      # @example Get video with transcript
      #   video = client.tiktok.video(
      #     "https://www.tiktok.com/@user/video/1234567890",
      #     get_transcript: true
      #   )
      #   puts video[:transcript]
      #
      # @example Response structure
      #   {
      #     id: "7445883744370625822",
      #     desc: "Video description",
      #     createTime: 1234567890,
      #     video: {
      #       duration: 15,
      #       ratio: "720p",
      #       cover: "https://...",
      #       downloadAddr: "https://..."
      #     },
      #     author: {
      #       id: "6659752019493208069",
      #       uniqueId: "stoolpresidente",
      #       nickname: "Dave Portnoy"
      #     },
      #     stats: {
      #       playCount: 1000000,
      #       diggCount: 50000,
      #       commentCount: 1000,
      #       shareCount: 5000
      #     },
      #     transcript: "..." # if get_transcript is true
      #   }
      def video(url, get_transcript: nil, region: nil, trim: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:getTranscript] = get_transcript unless get_transcript.nil?
        params[:region] = region if region
        params[:trim] = trim unless trim.nil?

        get("/v2/tiktok/video", params)
      end

      # Get TikTok video transcript
      #
      # Returns the transcript/captions for a TikTok video if available.
      # Useful for extracting spoken content from videos.
      #
      # @param url [String] TikTok video URL
      # @param language [String, nil] Language code for transcript (e.g., "en", "es")
      # @return [Hash] Transcript data
      # @raise [BadRequestError] If the url parameter is missing or invalid
      # @raise [NotFoundError] If the video is not found or has no transcript
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get video transcript
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   transcript = client.tiktok.video_transcript("https://www.tiktok.com/@user/video/1234567890")
      #   puts transcript[:text]
      #
      # @example Get transcript in specific language
      #   transcript = client.tiktok.video_transcript(
      #     "https://www.tiktok.com/@user/video/1234567890",
      #     language: "es"
      #   )
      def video_transcript(url, language: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:language] = language if language

        get("/v1/tiktok/video/transcript", params)
      end

      # Get TikTok user live stream status
      #
      # Returns information about whether a TikTok user is currently live streaming
      # and details about the live stream if active.
      #
      # @param handle [String] TikTok handle (username)
      # @return [Hash] Live stream status and information
      # @raise [BadRequestError] If the handle parameter is missing or invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Check if user is live
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   live = client.tiktok.user_live("stoolpresidente")
      #   puts live[:isLive]  # => true/false
      #
      # @example Response structure when live
      #   {
      #     isLive: true,
      #     liveRoom: {
      #       id: "7445883744370625822",
      #       title: "Live stream title",
      #       coverUrl: "https://...",
      #       stats: {
      #         viewerCount: 1000,
      #         totalUser: 5000
      #       }
      #     }
      #   }
      #
      # @example Response structure when not live
      #   {
      #     isLive: false
      #   }
      def user_live(handle)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        get("/v1/tiktok/user/live", { handle: handle })
      end
    end
  end
end
