# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Threads API resource
    #
    # Provides methods to interact with Threads endpoints for scraping public profile data,
    # posts, and search functionality.
    #
    # @see https://docs.scrapecreators.com/v1/threads Threads API Documentation
    class Threads < Resource
      # Get a public Threads profile
      #
      # Retrieves public profile information for a Threads user including username,
      # biography, follower count, verification status, and profile pictures.
      #
      # @param handle [String] Threads username
      # @return [Hash] Profile data including user info and follower counts
      # @raise [ArgumentError] If the handle parameter is nil or empty
      # @raise [BadRequestError] If the handle parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Threads profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   profile = client.threads.profile("sportsillustrated")
      #   puts profile[:username]       # => "sportsillustrated"
      #   puts profile[:full_name]      # => "Sports Illustrated"
      #   puts profile[:follower_count] # => 551296
      #   puts profile[:is_verified]    # => true
      #
      # @example Response structure
      #   {
      #     success: true,
      #     pk: "63496592589",
      #     text_post_app_is_private: false,
      #     has_onboarded_to_text_post_app: true,
      #     friendship_status: nil,
      #     profile_pic_url: "https://...",
      #     username: "sportsillustrated",
      #     follower_count: 551296,
      #     is_verified: true,
      #     biography: "Sports, sports and more sports.",
      #     text_app_biography: {
      #       text_fragments: {
      #         fragments: [...]
      #       }
      #     },
      #     full_name: "Sports Illustrated",
      #     bio_links: [
      #       {
      #         url: "https://lnk.bio/sportsillustrated",
      #         is_verified: false,
      #         link_id: "17882982429146262"
      #       }
      #     ],
      #     hd_profile_pic_versions: [
      #       { height: 320, url: "https://...", width: 320 },
      #       { height: 640, url: "https://...", width: 640 }
      #     ],
      #     is_threads_only_user: false,
      #     show_text_post_app_badge: true,
      #     id: "63496592589"
      #   }
      def profile(handle)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        get("/v1/threads/profile", handle: handle)
      end

      # Get posts from a Threads user
      #
      # Retrieves posts from a public Threads user's profile. Note that Threads only
      # allows access to the last 20-30 posts from a user.
      #
      # @param handle [String] Threads username
      # @param trim [Boolean] Set to true for a trimmed down version of the response (optional)
      # @return [Hash] Posts data including array of post objects
      # @raise [ArgumentError] If the handle parameter is nil or empty
      # @raise [BadRequestError] If the handle parameter is invalid
      # @raise [NotFoundError] If the user is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get posts from a Threads user
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   response = client.threads.user_posts("sportsillustrated")
      #   puts response[:posts].length
      #   response[:posts].each do |post|
      #     puts post[:caption][:text]
      #     puts post[:like_count]
      #   end
      #
      # @example Get trimmed posts data
      #   response = client.threads.user_posts("sportsillustrated", trim: true)
      #
      # @example Response structure
      #   {
      #     success: true,
      #     posts: [
      #       {
      #         id: "3536667222372268882_63496592589",
      #         pk: "3536667222372268882",
      #         code: "DEUxBnGRDtS",
      #         user: {
      #           pk: "63496592589",
      #           username: "sportsillustrated",
      #           profile_pic_url: "https://...",
      #           is_verified: true
      #         },
      #         caption: {
      #           text: "Post content here...",
      #           pk: "18298876294239445"
      #         },
      #         like_count: 6545,
      #         taken_at: 1735823609,
      #         media_type: 1,
      #         image_versions2: {
      #           candidates: [
      #             { height: 1800, url: "https://...", width: 1440 }
      #           ]
      #         },
      #         text_post_app_info: {
      #           reshare_count: 68,
      #           direct_reply_count: 159,
      #           repost_count: 217,
      #           quote_count: 34,
      #           reply_control: "everyone"
      #         },
      #         url: "https://www.threads.com/@sportsillustrated/post/DEUxBnGRDtS"
      #       }
      #     ]
      #   }
      def user_posts(handle, trim: nil)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        params = { handle: handle }
        params[:trim] = trim unless trim.nil?

        get("/v1/threads/user/posts", params)
      end

      # Get a single Threads post by URL
      #
      # Retrieves a post by its URL, including the post content, comments, and related posts.
      #
      # @param url [String] The URL of the Threads post
      # @param trim [Boolean] Set to true for a trimmed down version of the response (optional)
      # @return [Hash] Post data including post details, comments, and related posts
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the post is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Threads post
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   response = client.threads.post("https://www.threads.com/@trendspider/post/DIU8naHS6q_")
      #   puts response[:post][:caption][:text]
      #   puts response[:post][:like_count]
      #   puts response[:comments].length
      #   puts response[:related_posts].length
      #
      # @example Get trimmed post data
      #   response = client.threads.post("https://www.threads.com/@trendspider/post/DIU8naHS6q_", trim: true)
      #
      # @example Response structure
      #   {
      #     success: true,
      #     post: {
      #       id: "3608775792320555711_63069450921",
      #       pk: "3608775792320555711",
      #       code: "DIU8naHS6q_",
      #       user: {
      #         pk: "63069450921",
      #         username: "trendspider",
      #         profile_pic_url: "https://...",
      #         is_verified: false
      #       },
      #       caption: {
      #         text: "NVDA 🟢 = 36x P/E...",
      #         pk: "18109768954486098"
      #       },
      #       like_count: 28,
      #       taken_at: 1744419624,
      #       media_type: 1,
      #       image_versions2: {
      #         candidates: [
      #           { height: 790, url: "https://...", width: 1079 }
      #         ]
      #       },
      #       text_post_app_info: {
      #         reshare_count: 1,
      #         direct_reply_count: 6,
      #         repost_count: 1,
      #         quote_count: 0,
      #         reply_control: "everyone"
      #       }
      #     },
      #     comments: [
      #       {
      #         id: "3623864305260810977_63153846014",
      #         user: { username: "gringo.ronin", ... },
      #         caption: { text: "UNLIMITED FIREPOWAHHH", ... },
      #         like_count: 11
      #       }
      #     ],
      #     related_posts: [
      #       {
      #         id: "3608818157045893190_63438622220",
      #         user: { username: "jim.chuong", ... },
      #         caption: { text: "There is no reason to fear...", ... },
      #         like_count: 3
      #       }
      #     ]
      #   }
      def post(url, trim: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:trim] = trim unless trim.nil?

        get("/v1/threads/post", params)
      end
    end
  end
end
