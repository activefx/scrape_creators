# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Instagram API resource
    #
    # Provides methods to interact with Instagram endpoints for scraping public profile data,
    # posts, reels, comments, and more.
    #
    # @see https://docs.scrapecreators.com/v1/instagram Instagram API Documentation
    class Instagram < Resource
      # Get a public Instagram profile
      #
      # Scrapes a public Instagram profile including user information, recent posts,
      # bio links, and related accounts.
      #
      # @param handle [String] Instagram handle (username)
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Profile data including user info, posts, and related profiles
      # @raise [ArgumentError] If the handle parameter is nil or empty
      # @raise [BadRequestError] If the handle parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get an Instagram profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   profile = client.instagram.profile("adrianhorning")
      #   puts profile[:data][:user][:full_name]  # => "Adrian Horning"
      #   puts profile[:data][:user][:edge_followed_by][:count]  # => 25116
      #
      # @example Get a trimmed profile response
      #   profile = client.instagram.profile("adrianhorning", trim: true)
      #
      # @example Response structure
      #   {
      #     success: true,
      #     data: {
      #       user: {
      #         id: "2700692569",
      #         username: "adrianhorning",
      #         full_name: "Adrian Horning",
      #         biography: "Scraping the web",
      #         bio_links: [
      #           {
      #             title: "Social Media APIs",
      #             url: "https://scrapecreators.com",
      #             link_type: "external"
      #           }
      #         ],
      #         external_url: "https://scrapecreators.com/",
      #         edge_followed_by: { count: 25116 },
      #         edge_follow: { count: 101 },
      #         is_private: false,
      #         is_verified: true,
      #         is_business_account: true,
      #         profile_pic_url: "https://...",
      #         profile_pic_url_hd: "https://...",
      #         edge_owner_to_timeline_media: {
      #           count: 71,
      #           page_info: { has_next_page: true, end_cursor: "..." },
      #           edges: [
      #             {
      #               node: {
      #                 id: "3540614075954356349",
      #                 shortcode: "DEiyb48AeB9",
      #                 display_url: "https://...",
      #                 is_video: true,
      #                 edge_liked_by: { count: 126 },
      #                 edge_media_to_comment: { count: 12 }
      #               }
      #             }
      #           ]
      #         },
      #         edge_related_profiles: {
      #           edges: [
      #             {
      #               node: {
      #                 id: "66873381803",
      #                 username: "itsallykrinsky",
      #                 full_name: "ally"
      #               }
      #             }
      #           ]
      #         }
      #       }
      #     },
      #     status: "ok"
      #   }
      def profile(handle, trim: nil)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        params = { handle: handle }
        params[:trim] = trim unless trim.nil?

        get("/v1/instagram/profile", params)
      end

      # Get a basic Instagram profile by user ID
      #
      # Retrieves basic profile information for an Instagram user by their user ID.
      # This endpoint is currently free to use and provides essential profile data
      # including username, biography, follower/following counts, and verification status.
      #
      # @param user_id [String, Integer] Instagram user ID (numeric ID, not username)
      # @return [Hash] Basic profile data including user info and counts
      # @raise [ArgumentError] If the user_id parameter is nil or empty
      # @raise [BadRequestError] If the user_id parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      #
      # @example Get a basic Instagram profile by user ID
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   profile = client.instagram.basic_profile("314216")
      #   puts profile[:username]       # => "zuck"
      #   puts profile[:full_name]      # => "Mark Zuckerberg"
      #   puts profile[:follower_count] # => 16101999
      #   puts profile[:is_verified]    # => true
      #
      # @example Response structure
      #   {
      #     username: "zuck",
      #     pk: "314216",
      #     id: "314216",
      #     full_name: "Mark Zuckerberg",
      #     biography: "I build stuff",
      #     is_verified: true,
      #     is_private: false,
      #     is_business: false,
      #     follower_count: 16101999,
      #     following_count: 617,
      #     media_count: 409,
      #     profile_pic_url: "https://...",
      #     hd_profile_pic_url_info: { url: "https://..." },
      #     bio_links: [],
      #     external_url: "",
      #     account_type: 3,
      #     fbid_v2: "17841401746480004"
      #   }
      def basic_profile(user_id)
        raise ArgumentError, "user_id is required" if user_id.nil? || user_id.to_s.empty?

        get("/v1/instagram/basic-profile", userId: user_id)
      end

      # Get a public Instagram profile's posts
      #
      # Retrieves public posts from an Instagram profile including media details,
      # captions, engagement metrics, and pagination information.
      #
      # @param handle [String] Instagram handle (username)
      # @param next_max_id [String, nil] Cursor for pagination to get the next page of results
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Posts data including items array and pagination info
      # @raise [ArgumentError] If the handle parameter is nil or empty
      # @raise [BadRequestError] If the handle parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get posts from an Instagram profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   posts = client.instagram.posts("barstoolsports")
      #   puts posts[:num_results]       # => 12
      #   puts posts[:more_available]    # => true
      #   puts posts[:items].first[:id]  # => "3600545900919030401_260462810"
      #
      # @example Get next page of posts using cursor
      #   first_page = client.instagram.posts("barstoolsports")
      #   next_page = client.instagram.posts("barstoolsports", next_max_id: first_page[:next_max_id])
      #
      # @example Get trimmed posts response
      #   posts = client.instagram.posts("barstoolsports", trim: true)
      #
      # @example Response structure
      #   {
      #     num_results: 12,
      #     more_available: true,
      #     items: [
      #       {
      #         pk: "3600545900919030401",
      #         id: "3600545900919030401_260462810",
      #         code: "DH3tWudxIKB",
      #         media_type: 2,
      #         taken_at: 1743438570,
      #         caption: {
      #           text: "Caption text here",
      #           created_at: 1743438572
      #         },
      #         like_count: 387,
      #         comment_count: 12,
      #         play_count: 35499,
      #         user: {
      #           pk: "260462810",
      #           username: "barstoolsports",
      #           full_name: "Barstool Sports",
      #           is_verified: true
      #         },
      #         image_versions2: { candidates: [...] },
      #         video_versions: [...],
      #         url: "https://www.instagram.com/barstoolsports/p/DH3tWudxIKB/"
      #       }
      #     ],
      #     next_max_id: "3599731065704772932_260462810",
      #     user: {
      #       pk: "260462810",
      #       username: "barstoolsports",
      #       is_verified: true
      #     },
      #     status: "ok"
      #   }
      def posts(handle, next_max_id: nil, trim: nil)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        params = { handle: handle }
        params[:next_max_id] = next_max_id unless next_max_id.nil?
        params[:trim] = trim unless trim.nil?

        get("/v2/instagram/user/posts", params)
      end

      # Get detailed information about a specific Instagram post or reel
      #
      # Retrieves public detailed information about a specific Instagram post or reel
      # including media details, engagement metrics, comments, and owner information.
      #
      # @param url [String] Instagram post or reel URL
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Post/reel data including media info, engagement, and comments
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the post/reel is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get Instagram post details
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   post = client.instagram.post("https://www.instagram.com/p/DF5s0duxDts/")
      #   puts post[:data][:xdt_shortcode_media][:shortcode]  # => "DF5s0duxDts"
      #   puts post[:data][:xdt_shortcode_media][:owner][:username]  # => "adrianhorning"
      #
      # @example Get trimmed post response
      #   post = client.instagram.post("https://www.instagram.com/reel/DF5s0duxDts/", trim: true)
      #
      # @example Response structure
      #   {
      #     data: {
      #       xdt_shortcode_media: {
      #         __typename: "XDTGraphVideo",
      #         id: "3565077699422862188",
      #         shortcode: "DF5s0duxDts",
      #         thumbnail_src: "https://...",
      #         dimensions: { height: 1136, width: 640 },
      #         display_url: "https://...",
      #         has_audio: true,
      #         video_url: "https://...",
      #         video_view_count: 1639,
      #         video_play_count: 4651,
      #         video_duration: 71.1,
      #         is_video: true,
      #         taken_at_timestamp: 1739210435,
      #         owner: {
      #           id: "2700692569",
      #           username: "adrianhorning",
      #           is_verified: true,
      #           full_name: "Adrian Horning",
      #           profile_pic_url: "https://..."
      #         },
      #         edge_media_to_caption: {
      #           edges: [{ node: { text: "I built my own gumroad in 24 hours with AI" } }]
      #         },
      #         edge_media_preview_like: { count: 153 },
      #         edge_media_to_parent_comment: { count: 17 },
      #         clips_music_attribution_info: {
      #           artist_name: "adrianhorning",
      #           song_name: "Original audio"
      #         }
      #       }
      #     },
      #     extensions: { is_final: true },
      #     status: "ok"
      #   }
      def post(url, trim: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:trim] = trim unless trim.nil?

        get("/v1/instagram/post", params)
      end

      # Get the transcript of an Instagram post or reel
      #
      # Uses AI to transcribe the audio content of an Instagram post or reel.
      # This endpoint is slower than others (10-30 seconds) due to AI processing.
      # Returns null if no one is speaking in the video. For carousel posts,
      # returns a transcript for each item in the carousel.
      #
      # @param url [String] Instagram post or reel URL
      # @return [Hash] Transcript data including success status and transcripts array
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the post/reel is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get transcript for an Instagram reel
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.instagram.transcript("https://www.instagram.com/reel/DHsD6HGqJhp/")
      #   puts result[:success]  # => true
      #   puts result[:transcripts].first[:text]  # => "Let's fry up the perfect bunzel..."
      #
      # @example Response structure
      #   {
      #     success: true,
      #     transcripts: [
      #       {
      #         id: "3597267389859272809",
      #         shortcode: "DHsD6HGqJhp",
      #         text: "Let's fry up the perfect bunzel. Beautiful..."
      #       }
      #     ]
      #   }
      #
      # @example Response when no speech is detected
      #   {
      #     success: true,
      #     transcripts: [
      #       {
      #         id: "3597267389859272809",
      #         shortcode: "DHsD6HGqJhp",
      #         text: null
      #       }
      #     ]
      #   }
      def transcript(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v2/instagram/media/transcript", url: url)
      end

      # Search for Instagram reels by keyword
      #
      # Searches for reels matching a keyword. Can return a maximum of 60 reels.
      # Costs 1 credit per 10 reels. May be slower if requesting more than 20 reels
      # due to scraping search results first, then scraping each reel.
      #
      # @param query [String] Keyword to search for
      # @param amount [Integer, nil] Number of reels to return (max 60)
      # @return [Hash] Search results including reels array and credits remaining
      # @raise [ArgumentError] If the query parameter is nil or empty
      # @raise [BadRequestError] If the query parameter is invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Search for reels by keyword
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.instagram.search_reels("running")
      #   puts results[:success]           # => true
      #   puts results[:reels].count       # => 10
      #   puts results[:credits_remaining] # => 9981694
      #
      # @example Search with specific amount
      #   results = client.instagram.search_reels("fitness", amount: 20)
      #   puts results[:reels].count       # => 20
      #
      # @example Response structure
      #   {
      #     success: true,
      #     credits_remaining: 9981694,
      #     reels: [
      #       {
      #         id: "3744043036998479424",
      #         __typename: "XDTGraphVideo",
      #         shortcode: "DP1g04sEa5A",
      #         url: "https://www.instagram.com/reel/DP1g04sEa5A/",
      #         caption: "With the rising popularity of hybrid training...",
      #         thumbnail_src: "https://...",
      #         display_url: "https://...",
      #         video_url: "https://...",
      #         has_audio: false,
      #         video_view_count: 3770,
      #         video_play_count: 14750,
      #         product_type: "clips",
      #         video_duration: 49.866,
      #         clips_music_attribution_info: {
      #           artist_name: "joinladder",
      #           song_name: "Original audio",
      #           uses_original_audio: true,
      #           audio_id: "24452552341111704"
      #         },
      #         is_video: true,
      #         owner: {
      #           id: "2028540658",
      #           username: "joinladder",
      #           is_verified: true,
      #           profile_pic_url: "https://...",
      #           full_name: "Ladder",
      #           is_private: false,
      #           follower_count: 411575,
      #           post_count: 1107
      #         },
      #         taken_at: "2025-10-15T16:13:09.000Z",
      #         is_ad: false,
      #         like_count: 350,
      #         comment_count: 5,
      #         comments: [
      #           {
      #             id: "18012401585627100",
      #             text: "HYBRID 🐐!",
      #             owner: { id: "370586152", username: "edsel" },
      #             like_count: 1,
      #             created_at: "2025-10-15T17:20:33.000Z"
      #           }
      #         ],
      #         location: null
      #       }
      #     ]
      #   }
      def search_reels(query, amount: nil)
        raise ArgumentError, "query is required" if query.nil? || query.to_s.empty?

        params = { query: query }
        params[:amount] = amount unless amount.nil?

        get("/v1/instagram/reels/search", params)
      end

      # Get comments from an Instagram post or reel
      #
      # Retrieves comments from a public Instagram post or reel. Note that this
      # endpoint costs more than 1 credit - it costs 1 credit per 15 comments.
      # This won't return all comments, but a good number of them.
      #
      # @param url [String] Instagram post or reel URL
      # @param amount [Integer, nil] Number of comments to return (default: 15, max: ~300)
      # @return [Hash] Comments data including success status, credit cost, and comments array
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the post/reel is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get comments from an Instagram post
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.instagram.comments("https://www.instagram.com/p/ABC123/")
      #   puts result[:success]             # => true
      #   puts result[:num_comments_grabbed] # => 15
      #   puts result[:credit_cost]          # => 1
      #   puts result[:comments].first[:text] # => "Great post!"
      #
      # @example Get more comments with amount parameter
      #   result = client.instagram.comments("https://www.instagram.com/reel/XYZ789/", amount: 100)
      #   puts result[:num_comments_grabbed] # => 100
      #   puts result[:credit_cost]          # => 7
      #
      # @example Response structure
      #   {
      #     success: true,
      #     num_comments_grabbed: 343,
      #     credit_cost: 24,
      #     comments: [
      #       {
      #         id: "17916526530048829",
      #         text: "Great post!",
      #         created_at: "2025-01-17T14:07:40.000Z",
      #         user: {
      #           is_verified: false,
      #           id: "64101106104",
      #           pk: "64101106104",
      #           is_unpublished: nil,
      #           profile_pic_url: "https://...",
      #           username: "example_user",
      #           fbid_v2: "17841464143122638"
      #         }
      #       }
      #     ]
      #   }
      def comments(url, amount: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:amount] = amount unless amount.nil?

        get("/v1/instagram/post/comments", params)
      end
    end
  end
end
