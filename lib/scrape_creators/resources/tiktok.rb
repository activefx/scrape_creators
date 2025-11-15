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

      # Get TikTok video comments
      #
      # Scrapes comments from a TikTok video with pagination support.
      #
      # @param url [String] TikTok video URL
      # @param cursor [String, nil] Cursor for pagination to get more comments
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Comments data with comments array, cursor, and pagination info
      # @raise [BadRequestError] If the url parameter is missing or invalid
      # @raise [NotFoundError] If the video is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get video comments
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   comments = client.tiktok.video_comments("https://www.tiktok.com/@user/video/1234567890")
      #   puts comments[:comments].first[:text]
      #   puts comments[:has_more]  # => true/false
      #
      # @example Paginate through comments
      #   page1 = client.tiktok.video_comments("https://www.tiktok.com/@user/video/1234567890")
      #   page2 = client.tiktok.video_comments(
      #     "https://www.tiktok.com/@user/video/1234567890",
      #     cursor: page1[:cursor]
      #   )
      #
      # @example Response structure
      #   {
      #     comments: [
      #       {
      #         cid: "7463276288959824682",
      #         text: "Mesa and Scottsdale are like 2 different planets",
      #         create_time: 1737679448,
      #         digg_count: 1015,
      #         reply_comment_total: 9,
      #         user: {
      #           uid: "6851091024770040837",
      #           uniqueId: "tmoneyhoney18",
      #           nickname: "T"
      #         }
      #       }
      #     ],
      #     cursor: 20,
      #     has_more: 1,
      #     total: 269
      #   }
      def video_comments(url, cursor: nil, trim: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:cursor] = cursor if cursor
        params[:trim] = trim unless trim.nil?

        get("/v1/tiktok/video/comments", params)
      end

      # Get TikTok user following list
      #
      # Scrapes accounts that a TikTok user follows with pagination support.
      #
      # @param handle [String] TikTok handle (username)
      # @param min_time [Integer, nil] Cursor for pagination (get from previous response)
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Following data with followings array and pagination info
      # @raise [BadRequestError] If the handle parameter is missing or invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get user's following list
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   following = client.tiktok.user_following("stoolpresidente")
      #   puts following[:followings].first[:nickname]
      #   puts following[:has_more]  # => true/false
      #
      # @example Paginate through following list
      #   page1 = client.tiktok.user_following("stoolpresidente")
      #   page2 = client.tiktok.user_following("stoolpresidente", min_time: page1[:min_time])
      #
      # @example Response structure
      #   {
      #     followings: [
      #       {
      #         uid: "7436873095740343338",
      #         uniqueId: "barstoolgruden",
      #         nickname: "Barstool Gruden",
      #         signature: "SB XXXVII Champ currently @Barstool Sports",
      #         follower_count: 137712,
      #         following_count: 3,
      #         aweme_count: 121
      #       }
      #     ],
      #     has_more: true,
      #     min_time: 1694905758,
      #     max_time: 1737751308,
      #     total: 74
      #   }
      def user_following(handle, min_time: nil, trim: nil)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        params = { handle: handle }
        params[:min_time] = min_time if min_time
        params[:trim] = trim unless trim.nil?

        get("/v1/tiktok/user/following", params)
      end

      # Get TikTok user followers list
      #
      # Scrapes followers of a TikTok account with pagination support.
      # Requires either handle or user_id parameter. Using user_id provides faster response times.
      #
      # @param handle [String, nil] TikTok handle (username)
      # @param user_id [String, nil] TikTok user ID (faster response)
      # @param min_time [Integer, nil] Cursor for pagination (get from previous response)
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Followers data with followers array and pagination info
      # @raise [BadRequestError] If both handle and user_id are missing, or if parameters are invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get user's followers by handle
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   followers = client.tiktok.user_followers(handle: "stoolpresidente")
      #   puts followers[:followers].first[:nickname]
      #   puts followers[:has_more]  # => true/false
      #
      # @example Get user's followers by user ID (faster)
      #   followers = client.tiktok.user_followers(user_id: "6659752019493208069")
      #
      # @example Paginate through followers list
      #   page1 = client.tiktok.user_followers(handle: "stoolpresidente")
      #   page2 = client.tiktok.user_followers(
      #     handle: "stoolpresidente",
      #     min_time: page1[:min_time]
      #   )
      #
      # @example Response structure
      #   {
      #     followers: [
      #       {
      #         uid: "7463232156317287456",
      #         uniqueId: "jamal.voyage",
      #         nickname: "Jamal Voyage",
      #         follower_count: 0,
      #         following_count: 5,
      #         aweme_count: 0
      #       }
      #     ],
      #     has_more: true,
      #     min_time: 1737751140,
      #     max_time: 1737751376,
      #     total: 4108517
      #   }
      def user_followers(handle: nil, user_id: nil, min_time: nil, trim: nil)
        raise ArgumentError, "handle or user_id is required" if handle.nil? && user_id.nil?

        params = {}
        params[:handle] = handle if handle
        params[:user_id] = user_id if user_id
        params[:min_time] = min_time if min_time
        params[:trim] = trim unless trim.nil?

        get("/v1/tiktok/user/followers", params)
      end
    end
  end
end
