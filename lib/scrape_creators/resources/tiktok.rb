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
      #   puts profile[:stats][:follower_count]  # => 4100000
      #
      # @example Response structure
      #   {
      #     user: {
      #       id: "6659752019493208069",
      #       unique_id: "stoolpresidente",
      #       nickname: "Dave Portnoy",
      #       avatar_larger: "https://...",
      #       signature: "El Presidente/Barstool Sports Founder.",
      #       verified: true,
      #       bio_link: { link: "https://...", risk: 0 },
      #       private_account: false,
      #       ...
      #     },
      #     stats: {
      #       follower_count: 4100000,
      #       following_count: 74,
      #       heart: 190400000,
      #       video_count: 2017,
      #       ...
      #     },
      #     item_list: []
      #   }
      def profile(handle)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        response = get("/v1/tiktok/profile", { handle: handle })

        # Handle account_deactivated flag in 200 responses
        if response[:account_deactivated]
          raise NotFoundError.new(
            response[:message] || "Profile not found",
            response_body: response
          )
        end

        response
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
      #   puts audience[:audience_locations].first[:country]  # => "Mexico"
      #   puts audience[:audience_locations].first[:percentage]  # => "15.96%"
      #
      # @example Response structure
      #   {
      #     success: true,
      #     audience_locations: [
      #       {
      #         country: "Mexico",
      #         country_code: "MX",
      #         count: 83,
      #         percentage: "15.96%"
      #       },
      #       {
      #         country: "United States",
      #         country_code: "US",
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
      #   puts videos[:item_list].first[:desc]  # Video description
      #   puts videos[:has_more]  # => true/false
      #
      # @example Get oldest videos first
      #   videos = client.tiktok.profile_videos("stoolpresidente", sort_by: "oldest")
      #
      # @example Paginate through results
      #   page1 = client.tiktok.profile_videos("handle")
      #   page2 = client.tiktok.profile_videos("handle", max_cursor: page1[:max_cursor])
      #
      # @example Response structure
      #   {
      #     item_list: [
      #       {
      #         id: "7445883744370625822",
      #         desc: "Video description",
      #         create_time: 1234567890,
      #         video: { ... },
      #         statistics: { digg_count: 123, share_count: 45, ... }
      #       }
      #     ],
      #     cursor: "123456",
      #     max_cursor: "789012",
      #     has_more: true
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
      #     item_list: [
      #       {
      #         id: "7445883744370625822",
      #         desc: "Video description",
      #         create_time: 1234567890,
      #         video: { ... },
      #         statistics: { digg_count: 123, share_count: 45, ... }
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

        response = get("/v3/tiktok/profile-videos", params)

        # API returns an array at top level, wrap it in a hash
        if response.is_a?(Array)
          { item_list: response }
        else
          response
        end
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
      #   puts video[:statistics][:play_count]  # View count
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
      #     create_time: 1234567890,
      #     video: {
      #       duration: 15,
      #       ratio: "720p",
      #       cover: "https://...",
      #       download_addr: "https://..."
      #     },
      #     author: {
      #       id: "6659752019493208069",
      #       unique_id: "stoolpresidente",
      #       nickname: "Dave Portnoy"
      #     },
      #     statistics: {
      #       play_count: 1000000,
      #       digg_count: 50000,
      #       comment_count: 1000,
      #       share_count: 5000
      #     },
      #     transcript: "..." # if get_transcript is true
      #   }
      def video(url, get_transcript: nil, region: nil, trim: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:getTranscript] = get_transcript unless get_transcript.nil?
        params[:region] = region if region
        params[:trim] = trim unless trim.nil?

        response = get("/v2/tiktok/video", params)

        # Extract aweme_detail from the response wrapper
        aweme_detail = response[:aweme_detail] || response

        # Check if video data is actually present
        unless aweme_detail[:id] || aweme_detail[:aweme_id]
          raise NotFoundError.new(
            "Video not found or unavailable",
            response_body: response
          )
        end

        aweme_detail
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
      #   # Check if live_room_user_info is present and has data
      #   is_live = live[:live_room_user_info]&.any?
      #
      # @example Response structure when live
      #   {
      #     live_room_user_info: {
      #       # Live room data
      #     }
      #   }
      #
      # @example Response structure when not live
      #   {
      #     live_room_user_info: {}
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
      #           unique_id: "tmoneyhoney18",
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
      #         unique_id: "barstoolgruden",
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
      #         unique_id: "jamal.voyage",
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

      # Search TikTok users by query
      #
      # Scrapes TikTok users matching a search query with pagination support.
      #
      # @param query [String] Search query for users
      # @param cursor [Integer, String, nil] Cursor for pagination to get more users
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Search results with users array and cursor for pagination
      # @raise [BadRequestError] If the query parameter is missing or invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Search for users
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.tiktok.search_users("taylorswift")
      #   puts results[:user_list].first[:user_info][:nickname]  # => "Taylor Swift"
      #   puts results[:cursor]  # => 10
      #
      # @example Paginate through search results
      #   page1 = client.tiktok.search_users("taylorswift")
      #   page2 = client.tiktok.search_users("taylorswift", cursor: page1[:cursor])
      #
      # @example Get trimmed response
      #   results = client.tiktok.search_users("taylorswift", trim: true)
      #
      # @example Response structure
      #   {
      #     cursor: 10,
      #     user_list: [
      #       {
      #         user_info: {
      #           uid: "6881290705605477381",
      #           unique_id: "taylorswift",
      #           nickname: "Taylor Swift",
      #           avatar_thumb: { url_list: [...] },
      #           signature: "...",
      #           follower_count: 32691341,
      #           following_count: 0,
      #           aweme_count: 71,
      #           total_favorited: 247401086,
      #           verification_type: 1,
      #           custom_verify: "Verified account",
      #           ...
      #         }
      #       }
      #     ]
      #   }
      def search_users(query, cursor: nil, trim: nil)
        raise ArgumentError, "query is required" if query.nil? || query.to_s.empty?

        params = { query: query }
        params[:cursor] = cursor if cursor
        params[:trim] = trim unless trim.nil?

        get("/v1/tiktok/search/users", params)
      end

      # Search TikTok videos by keyword
      #
      # Scrapes TikTok videos matching a keyword search with pagination support.
      # Allows filtering by date posted, sorting options, and region-specific proxies.
      #
      # @param query [String] Keyword to search for
      # @param date_posted [String, nil] Time frame filter for videos
      #   Options: "yesterday", "this-week", "this-month", "last-3-months", "last-6-months", "all-time"
      # @param sort_by [String, nil] Sort order for results
      #   Options: "relevance", "most-liked", "date-posted"
      # @param region [String, nil] Two-letter country code for proxy location (e.g., "US", "GB", "FR")
      #   Note: This doesn't filter videos by region, it sets the proxy location for scraping
      # @param cursor [Integer, String, nil] Cursor for pagination to get more videos
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Search results with videos array and cursor for pagination
      # Search TikTok "Top" search results
      #
      # Performs a TikTok "Top" search which returns both Photo Carousels and Videos,
      # unlike the regular keyword search which only returns Videos.
      #
      # @param query [String] Keyword to search for
      # @param publish_time [String, nil] Time frame TikTok was posted.
      #   Options: "yesterday", "this-week", "this-month", "last-3-months",
      #   "last-6-months", "all-time"
      # @param sort_by [String, nil] Sort order.
      #   Options: "relevance", "most-liked", "date-posted"
      # @param region [String, nil] Region for proxy placement (2-letter country code like US, GB, FR).
      #   Note: This doesn't filter results to a specific region, it places the proxy there.
      # @param cursor [Integer, String, nil] Cursor for pagination (get from previous response)
      # @return [Hash] Search results with items array and cursor for pagination
      # @raise [BadRequestError] If the query parameter is missing or invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Search for videos by keyword
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.tiktok.search_keyword("super bowl")
      #   puts results[:search_item_list].first[:aweme_info][:desc]
      #   puts results[:cursor]
      #
      # @example Search with filters
      #   results = client.tiktok.search_keyword(
      #     "cooking recipes",
      #     date_posted: "this-week",
      #     sort_by: "most-liked"
      #   )
      #
      # @example Paginate through search results
      #   page1 = client.tiktok.search_keyword("dance")
      #   page2 = client.tiktok.search_keyword("dance", cursor: page1[:cursor])
      #
      # @example Get trimmed response
      #   results = client.tiktok.search_keyword("music", trim: true)
      #
      # @example Response structure
      #   {
      #     cursor: 12,
      #     search_item_list: [
      #       {
      #         aweme_info: {
      #           aweme_id: "7334621391758642478",
      #           desc: "The most insane Super Bowl ever...",
      #           create_time: 1707724682,
      #           author: {
      #             unique_id: "username",
      #             nickname: "User Name",
      #             ...
      #           },
      #           statistics: {
      #             digg_count: 355,
      #             comment_count: 5,
      #             play_count: 31677,
      #             share_count: 22
      #           },
      #           video: { ... },
      #           music: { ... },
      #           ...
      #         }
      #       }
      #     ]
      #   }
      def search_keyword(query, date_posted: nil, sort_by: nil, region: nil, cursor: nil, trim: nil)
        raise ArgumentError, "query is required" if query.nil? || query.to_s.empty?

        params = { query: query }
        params[:date_posted] = date_posted if date_posted
        params[:sort_by] = sort_by if sort_by
        params[:region] = region if region
        params[:cursor] = cursor if cursor
        params[:trim] = trim unless trim.nil?

        get("/v1/tiktok/search/keyword", params)
      # @example Basic search
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.tiktok.search_top("dance")
      #   puts results[:items].first[:desc]  # Video/carousel description
      #   puts results[:cursor]  # => 30
      #
      # @example Search with filters
      #   results = client.tiktok.search_top(
      #     "dance",
      #     publish_time: "this-week",
      #     sort_by: "most-liked",
      #     region: "US"
      #   )
      #
      # @example Paginate through search results
      #   page1 = client.tiktok.search_top("dance")
      #   page2 = client.tiktok.search_top("dance", cursor: page1[:cursor])
      #
      # @example Response structure
      #   {
      #     success: true,
      #     items: [
      #       {
      #         id: "7528150371680767263",
      #         desc: "Video description #dance #trend",
      #         content_type: "video",
      #         create_time: "2025-07-17T20:28:28.000Z",
      #         region: "US",
      #         statistics: {
      #           play_count: 17897,
      #           digg_count: 1895,
      #           comment_count: 83,
      #           share_count: 27
      #         },
      #         video: { ... },
      #         author: { ... },
      #         url: "https://www.tiktok.com/@user/video/123"
      #       }
      #     ],
      #     cursor: 30
      #   }
      def search_top(query, publish_time: nil, sort_by: nil, region: nil, cursor: nil)
        raise ArgumentError, "query is required" if query.nil? || query.to_s.empty?

        params = { query: query }
        params[:publish_time] = publish_time if publish_time
        params[:sort_by] = sort_by if sort_by
        params[:region] = region if region
        params[:cursor] = cursor if cursor

        get("/v1/tiktok/search/top", params)
      end
      
      # Search TikTok videos by hashtag
      #
      # Scrapes TikTok videos matching a hashtag with pagination support.
      #
      # @param hashtag [String] Hashtag to search for (without the # symbol)
      # @param region [String, nil] Region code for proxy location (e.g., "US", "UK")
      # @param cursor [Integer, String, nil] Cursor for pagination to get more videos
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Search results with videos array and cursor for pagination
      # @raise [BadRequestError] If the hashtag parameter is missing or invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Search for videos by hashtag
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.tiktok.search_hashtag("fyp")
      #   puts results[:aweme_list].first[:desc]  # Video description
      #   puts results[:cursor]  # => 12
      #   puts results[:has_more]  # => 1
      #
      # @example Paginate through search results
      #   page1 = client.tiktok.search_hashtag("fyp")
      #   page2 = client.tiktok.search_hashtag("fyp", cursor: page1[:cursor])
      #
      # @example Search with region parameter
      #   results = client.tiktok.search_hashtag("fyp", region: "US")
      #
      # @example Get trimmed response
      #   results = client.tiktok.search_hashtag("fyp", trim: true)
      #
      # @example Response structure
      #   {
      #     aweme_list: [
      #       {
      #         aweme_id: "6862153058223197445",
      #         desc: "To the 🐝 🐝 🐝  #fyp",
      #         create_time: 1597719521,
      #         author: {
      #           uid: "6748458643983238149",
      #           unique_id: "bellapoarch",
      #           nickname: "Bella Poarch"
      #         },
      #         statistics: {
      #           play_count: 852942803,
      #           digg_count: 68933772,
      #           comment_count: 2901351,
      #           share_count: 42457977
      #         },
      #         video: { ... },
      #         music: { ... }
      #       }
      #     ],
      #     cursor: 12,
      #     has_more: 1,
      #     status_code: 0,
      #     status_msg: ""
      #   }
      def search_hashtag(hashtag, region: nil, cursor: nil, trim: nil)
        raise ArgumentError, "hashtag is required" if hashtag.nil? || hashtag.to_s.empty?

        params = { hashtag: hashtag }
        params[:region] = region if region
        params[:cursor] = cursor if cursor
        params[:trim] = trim unless trim.nil?

        get("/v1/tiktok/search/hashtag", params)
      end
    end
  end
end
