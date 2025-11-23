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
      end

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

      # Get popular songs from TikTok
      #
      # Retrieves a list of popular songs from TikTok's Creative Center.
      # This endpoint can take up to 30 seconds to respond.
      #
      # @note This endpoint scrapes data from https://ads.tiktok.com/business/creativecenter/inspiration/popular/music/pc/en
      #
      # @param page [Integer, nil] Page number for pagination
      # @param time_period [Integer, nil] Time period to get popular songs from
      #   Options: 7, 30, 120 (days)
      # @param rank_type [String, nil] Get popular or surging songs
      #   Options: "popular", "surging"
      # @param new_on_board [Boolean, nil] Filter for songs new to top 100
      # @param commercial_music [Boolean, nil] Filter for songs approved for business use
      # @param country_code [String, nil] Country code to get popular songs from
      #   Options: AR, AU, AT, BH, BD, BY, BE, BR, BG, KH, CA, CL, CO, HR, CZ, DK, EG, EE,
      #   FI, FR, DE, GR, HU, IS, ID, IQ, IE, IL, IT, JP, JO, KZ, KW, LV, LB, LT, LU, MO,
      #   MY, MX, MA, MM, NL, NZ, NG, NO, OM, PK, PE, PH, PL, PT, QA, RO, SA, SG, SK, ZA,
      #   KR, ES, SE, CH, TW, TH, TR, UA, AE, GB, US, UZ, VN
      # @return [Hash] Popular songs data with pagination info and song list
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get popular songs
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   songs = client.tiktok.popular_songs
      #   puts songs[:sound_list].first[:title]  # => "luther"
      #   puts songs[:sound_list].first[:author]  # => "Kendrick Lamar & SZA"
      #
      # @example Get popular songs with filters
      #   songs = client.tiktok.popular_songs(
      #     time_period: 7,
      #     rank_type: "surging",
      #     country_code: "US"
      #   )
      #
      # @example Filter for commercial music
      #   songs = client.tiktok.popular_songs(commercial_music: true)
      #
      # @example Paginate through results
      #   page1 = client.tiktok.popular_songs
      #   page2 = client.tiktok.popular_songs(page: 2) if page1.dig(:pagination, :has_more)
      #
      # @example Response structure
      #   {
      #     pagination: {
      #       page: 1,
      #       size: 20,
      #       total: 99,
      #       has_more: true
      #     },
      #     sound_list: [
      #       {
      #         author: "Kendrick Lamar & SZA",
      #         clip_id: "7439295283975702544",
      #         country_code: "US",
      #         cover: "https://...",
      #         duration: 59,
      #         if_cml: false,
      #         is_search: false,
      #         link: "https://www.tiktok.com/music/x-7439295283975702544",
      #         promoted: false,
      #         rank: 1,
      #         rank_diff: 1,
      #         rank_diff_type: 1,
      #         related_items: [...],
      #         song_id: "7440101671265486864",
      #         title: "luther",
      #         trend: [...],
      #         url_title: "luther"
      #       }
      #     ]
      #   }
      def popular_songs(page: nil, time_period: nil, rank_type: nil, new_on_board: nil,
                        commercial_music: nil, country_code: nil)
        params = {}
        params[:page] = page if page
        params[:timePeriod] = time_period if time_period
        params[:rankType] = rank_type if rank_type
        params[:newOnBoard] = new_on_board unless new_on_board.nil?
        params[:commercialMusic] = commercial_music unless commercial_music.nil?
        params[:countryCode] = country_code if country_code

        get("/v1/tiktok/songs/popular", params)
      end

      # Get TikTok song details
      #
      # Scrapes detailed information about a specific TikTok song/sound by its clip ID.
      # Note: The parameter is called clipId (not songId) because TikTok allows
      # clipping different portions of a song.
      #
      # @param clip_id [String] The clip ID of the song (found in popular_songs response as clip_id)
      # @return [Hash] Song details including music info, metadata, and share information
      # @raise [ArgumentError] If the clip_id parameter is nil or empty
      # @raise [NotFoundError] If the song is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get song details
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   song = client.tiktok.song("6717159721276540930")
      #   puts song[:music_info][:title]  # => "Different (Acoustic)"
      #   puts song[:music_info][:author]  # => "Micah Tyler"
      #
      # @example Get song from popular_songs response
      #   songs = client.tiktok.popular_songs
      #   clip_id = songs[:sound_list].first[:clip_id]
      #   song_details = client.tiktok.song(clip_id)
      #
      # @example Response structure
      #   {
      #     music_info: {
      #       album: "Different",
      #       author: "Micah Tyler",
      #       title: "Different (Acoustic)",
      #       duration: 60,
      #       id: 6717159721276541000,
      #       id_str: "6717159721276540930",
      #       play_url: { uri: "https://...", url_list: [...] },
      #       cover_large: { uri: "...", url_list: [...] },
      #       cover_medium: { uri: "...", url_list: [...] },
      #       cover_thumb: { uri: "...", url_list: [...] },
      #       artists: [...],
      #       user_count: 358,
      #       is_commerce_music: true,
      #       is_original: false,
      #       share_info: {
      #         share_url: "https://www.tiktok.com/music/...",
      #         share_title: "...",
      #         share_desc: "..."
      #       },
      #       matched_song: {
      #         title: "Different (Acoustic)",
      #         author: "Micah Tyler",
      #         full_duration: 195120
      #       },
      #       full_song: {
      #         full_song_duration: 195,
      #         full_song_id: "6739983931317159937",
      #         full_song_play_url: { uri: "...", url_list: [...] }
      #       }
      #     },
      #     status_code: 0,
      #     status_msg: ""
      #   }
      def song(clip_id)
        raise ArgumentError, "clip_id is required" if clip_id.nil? || clip_id.to_s.empty?

        get("/v1/tiktok/song", { clipId: clip_id })
      end

      # Get TikTok videos using a specific song
      #
      # Retrieves a list of TikTok videos that use a specific song/sound.
      # Supports cursor-based pagination for fetching more results.
      #
      # @param clip_id [String] The clip ID of the song. Can be found in song URLs like
      #   https://www.tiktok.com/music/Song-Name-7370375686554782506 where
      #   7370375686554782506 is the clip_id
      # @param cursor [Integer, String, nil] Cursor for pagination to get more videos
      # @return [Hash] Videos data with aweme_list array and cursor for pagination
      # @raise [ArgumentError] If the clip_id parameter is nil or empty
      # @raise [NotFoundError] If the song is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get videos using a song
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   videos = client.tiktok.song_videos("7370375686554782506")
      #   puts videos[:aweme_list].first[:desc]  # Video description
      #   puts videos[:has_more]  # => 1
      #
      # @example Paginate through videos
      #   page1 = client.tiktok.song_videos("7370375686554782506")
      #   page2 = client.tiktok.song_videos("7370375686554782506", cursor: page1[:cursor])
      #
      # @example Get videos from popular_songs response
      #   songs = client.tiktok.popular_songs
      #   clip_id = songs[:sound_list].first[:clip_id]
      #   videos = client.tiktok.song_videos(clip_id)
      #
      # @example Response structure
      #   {
      #     aweme_list: [
      #       {
      #         aweme_id: "7452069943757114646",
      #         desc: "Video description #hashtag",
      #         create_time: 1735070246,
      #         author: {
      #           uid: "7431412724132922400",
      #           unique_id: "username",
      #           nickname: "User Name"
      #         },
      #         statistics: {
      #           play_count: 2932976,
      #           digg_count: 197747,
      #           comment_count: 347,
      #           share_count: 26467
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
      def song_videos(clip_id, cursor: nil)
        raise ArgumentError, "clip_id is required" if clip_id.nil? || clip_id.to_s.empty?

        params = { clipId: clip_id }
        params[:cursor] = cursor if cursor

        get("/v1/tiktok/song/videos", params)
      end

      # Get the trending feed from TikTok
      #
      # Retrieves trending videos from TikTok's For You feed based on a specific region.
      # The region parameter sets the proxy location for scraping, which affects what
      # content is accessible (content that isn't banned in that region).
      #
      # @param region [String] Two-letter country code for proxy location (e.g., "US", "GB", "FR")
      #   This doesn't filter videos by region, it sets the proxy location for scraping
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Trending videos data with aweme_list array
      # @raise [ArgumentError] If the region parameter is nil or empty
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get trending videos from US region
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   trending = client.tiktok.trending_feed("US")
      #   puts trending[:aweme_list].first[:desc]  # Video description
      #   puts trending[:aweme_list].first[:statistics][:play_count]  # View count
      #
      # @example Get trending videos with trimmed response
      #   trending = client.tiktok.trending_feed("US", trim: true)
      #
      # @example Response structure
      #   {
      #     aweme_list: [
      #       {
      #         aweme_id: "7540000301621841183",
      #         desc: "#hudsonvalley #fallgetaway #farm #upstateny #resort",
      #         desc_language: "un",
      #         region: "US",
      #         statistics: {
      #           aweme_id: "7540000301621841183",
      #           comment_count: 646,
      #           digg_count: 71423,
      #           download_count: 130,
      #           play_count: 1443873,
      #           share_count: 8440,
      #           collect_count: 21957
      #         },
      #         video: {
      #           play_addr: { uri: "...", url_list: [...] },
      #           cover: { uri: "...", url_list: [...] }
      #         },
      #         author: {
      #           uid: "6754760670083138566",
      #           nickname: "Bre 🤍",
      #           signature: "3rd grade teacher 🍎...",
      #           sec_uid: "MS4wLjABAAAA..."
      #         },
      #         create_time: 1755543133,
      #         create_time_utc: "2025-08-18T18:52:13.000Z",
      #         url: "https://www.tiktok.com/@breannafriedman0/photo/7540000301621841183",
      #         is_ad: false
      #       }
      #     ]
      #   }
      def trending_feed(region, trim: nil)
        raise ArgumentError, "region is required" if region.nil? || region.to_s.empty?

        params = { region: region }
        params[:trim] = trim unless trim.nil?

        get("/v1/tiktok/get-trending-feed", params)
      end

      # Search TikTok Shop products
      #
      # Scrapes TikTok Shop products from a search query. This endpoint handles pagination
      # automatically and can return up to around 500 products per search.
      #
      # @note This endpoint costs more than 1 credit! Since pagination is handled automatically,
      #   it costs 1 credit per page (TikTok returns 30 products per page). This endpoint may
      #   take a while to respond.
      #
      # @param query [String] Search term for products
      # @param amount [Integer, nil] Number of products to scrape (limited by TikTok's restrictions)
      # @return [Hash] Search results with products array
      # @raise [ArgumentError] If the query parameter is nil or empty
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Search for products
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.tiktok.shop_search("shoes")
      #   puts results[:total_products]  # => 100
      #   puts results[:products].first[:title]  # => "Crocs Adult Classic Clogs"
      #
      # @example Search with specific amount
      #   results = client.tiktok.shop_search("electronics", amount: 50)
      #   puts results[:products].length
      #
      # @example Response structure
      #   {
      #     success: true,
      #     query: "shoes",
      #     total_products: 100,
      #     products: [
      #       {
      #         product_id: "1730213444857467838",
      #         title: "Crocs Adult Classic Clogs",
      #         image: {
      #           height: 1200,
      #           width: 1200,
      #           uri: "tos-useast5-i-omjb5zjo8w-tx/...",
      #           url_list: ["https://..."]
      #         },
      #         product_price_info: {
      #           currency_symbol: "$",
      #           sale_price_decimal: "49.99",
      #           sale_price_format: "49.99"
      #         },
      #         rate_info: {
      #           score: 4.8,
      #           review_count: "2493"
      #         },
      #         sold_info: {
      #           sold_count: 24737
      #         },
      #         seller_info: {
      #           seller_id: "7495832567110863806",
      #           shop_name: "Crocs",
      #           shop_logo: { ... }
      #         },
      #         seo_url: {
      #           canonical_url: "https://www.tiktok.com/shop/pdp/...",
      #           slug: "classic-clogs-by-crocs-..."
      #         }
      #       }
      #     ]
      #   }
      def shop_search(query, amount: nil)
        raise ArgumentError, "query is required" if query.nil? || query.to_s.empty?

        params = { query: query }
        params[:amount] = amount if amount

        get("/v1/tiktok/shop/search", params)
      end

      # Get TikTok Shop product details
      #
      # Retrieves detailed information about a TikTok Shop product including stock levels,
      # related affiliate videos promoting the product, seller information, and more.
      #
      # @param url [String] The URL of the TikTok Shop product to get details for
      # @param get_related_videos [Boolean, nil] Whether to get related videos for the product.
      #   These are affiliate videos promoting the product. Note: This will take longer to process.
      # @param region [String, nil] Region the proxy will be set to so you can access products
      #   from that country. Use 2 letter country codes like US, GB, FR, etc.
      # @return [Hash] Product details including product_info, shop_info, categories, and optionally related_videos
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [NotFoundError] If the product is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get product details
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   product = client.tiktok.shop_product("https://www.tiktok.com/shop/product/123")
      #   puts product[:product_info][:product_base][:title]  # => "Product Name"
      #   puts product[:product_info][:skus].first[:stock]  # => 1824
      #
      # @example Get product with related affiliate videos
      #   product = client.tiktok.shop_product(
      #     "https://www.tiktok.com/shop/product/123",
      #     get_related_videos: true
      #   )
      #   puts product[:related_videos].first[:title]
      #
      # @example Get product from specific region
      #   product = client.tiktok.shop_product(
      #     "https://www.tiktok.com/shop/product/123",
      #     region: "US"
      #   )
      #
      # Get products from a TikTok Shop
      #
      # Retrieves all products from a TikTok Shop by its URL. This endpoint handles
      # pagination automatically and can take a while to respond.
      #
      # @note This endpoint costs more than 1 credit! Since pagination is handled
      #   automatically, it costs 1 credit per page (TikTok returns 30 products per page).
      #   This endpoint may take a while and is new, so please be patient.
      #
      # @param url [String] The URL of the TikTok Shop
      # @param amount [Integer, nil] The amount of products to get
      # @return [Hash] Shop info and products data
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get products from a shop
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.tiktok.shop_products("https://www.tiktok.com/shop/store/goli-nutrition/7495794203056835079")
      #   puts results[:shop_info][:shop_name]  # => "Goli Nutrition"
      #   puts results[:products].first[:title]  # => "Goli Ashwagandha..."
      #
      # @example Get specific amount of products
      #   results = client.tiktok.shop_products(
      #     "https://www.tiktok.com/shop/store/goli-nutrition/7495794203056835079",
      #     amount: 50
      #   )
      #
      # @example Response structure
      #   {
      #     success: true,
      #     categories: [
      #       {
      #         category_id: "601450",
      #         category_name: "Beauty & Personal Care",
      #         level: 1,
      #         is_leaf: false
      #       }
      #     ],
      #     sale_region: "US",
      #     product_info: {
      #       product_id: "1730383241618035288",
      #       status: 1,
      #       seller: {
      #         seller_id: "7496021452055022168",
      #         name: "Manspot",
      #         avatar: { ... },
      #         product_count: 14,
      #         seller_location: "United States of America"
      #       },
      #       product_base: {
      #         title: "Product Title",
      #         images: [...],
      #         sold_count: 7160,
      #         price: {
      #           original_price: "$39.99",
      #           real_price: "$21.99",
      #           discount: "-47%",
      #           currency: "USD"
      #         }
      #       },
      #       sale_props: [...],
      #       skus: [
      #         {
      #           sku_id: "1730384306561520216",
      #           stock: 1824,
      #           purchase_limit: 20,
      #           price: { ... }
      #         }
      #       ],
      #       product_detail_review: {
      #         product_rating: 4.3,
      #         review_count: 595,
      #         review_items: [...]
      #       }
      #     },
      #     shop_info: {
      #       seller_id: "7496021452055022168",
      #       shop_name: "Manspot",
      #       sold_count: 50887,
      #       review_count: 4215,
      #       shop_rating: "4.4",
      #       shop_link: "https://www.tiktok.com/shop/store/manspot/..."
      #     },
      #     shop_performance: [
      #       { score_percentile: 98, type: 1 },
      #       { score_percentile: 97, type: 2 }
      #     ],
      #     related_videos: [  # Only present if get_related_videos is true
      #       {
      #         item_id: "7527142083258305822",
      #         title: "Video title",
      #         play_count: 324944,
      #         like_count: 1812,
      #         author_name: "Author Name",
      #         url: "https://www.tiktok.com/@user/video/123"
      #       }
      #     ]
      #   }
      def shop_product(url, get_related_videos: nil, region: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:get_related_videos] = get_related_videos unless get_related_videos.nil?
        params[:region] = region if region

        get("/v1/tiktok/product", params)
      end

      #     shop_info: {
      #       seller_id: "7495794203056835079",
      #       sold_count: 3767605,
      #       on_sell_product_count: 36,
      #       review_count: 284185,
      #       shop_name: "Goli Nutrition",
      #       shop_logo: { ... },
      #       shop_rating: "4.6",
      #       shop_link: "https://www.tiktok.com/shop/store/goli-nutrition/...",
      #       format_sold_count: "3.7M",
      #       region: "US",
      #       followers_count: "237879",
      #       store_sub_score: [...]
      #     },
      #     products: [
      #       {
      #         product_id: "1729527313880355335",
      #         title: "Goli Ashwagandha & Vitamin D Gummy...",
      #         image: { ... },
      #         product_price_info: {
      #           currency_symbol: "$",
      #           sale_price_decimal: "14.96",
      #           origin_price_decimal: "24.99",
      #           discount_format: "40%"
      #         },
      #         rate_info: {
      #           score: 4.5,
      #           review_count: "91316"
      #         },
      #         sold_info: {
      #           sold_count: 1235089
      #         },
      #         seller_info: { ... },
      #         seo_url: {
      #           canonical_url: "https://www.tiktok.com/shop/pdp/...",
      #           slug: "ashwagandha-gummies-by-goli-..."
      #         }
      #       }
      #     ]
      #   }
      def shop_products(url, amount: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:amount] = amount if amount

        get("/v1/tiktok/shop/products", params)
      end
    end
  end
end
