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
    end
  end
end
