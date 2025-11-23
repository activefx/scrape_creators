# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Truth Social API resource
    #
    # Provides methods to interact with Truth Social endpoints for scraping public profile data
    # and posts.
    #
    # @see https://docs.scrapecreators.com/v1/truth-social Truth Social API Documentation
    class TruthSocial < Resource
      # Get a public Truth Social profile
      #
      # Retrieves public profile information for a Truth Social user including
      # display name, bio, follower/following counts, verification status, and more.
      #
      # @param handle [String] Truth Social username
      # @return [Hash] Profile data including user info and counts
      # @raise [ArgumentError] If the handle parameter is nil or empty
      # @raise [BadRequestError] If the handle parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Truth Social profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   profile = client.truth_social.profile("realDonaldTrump")
      #   puts profile[:display_name]     # => "Donald J. Trump"
      #   puts profile[:followers_count]  # => 9528475
      #   puts profile[:verified]         # => true
      #
      # @example Response structure
      #   {
      #     success: true,
      #     id: "107780257626128497",
      #     username: "realDonaldTrump",
      #     acct: "realDonaldTrump",
      #     display_name: "Donald J. Trump",
      #     locked: false,
      #     bot: false,
      #     discoverable: nil,
      #     group: false,
      #     created_at: "2022-02-11T16:16:57.705Z",
      #     note: "<p></p>",
      #     url: "https://truthsocial.com/@realDonaldTrump",
      #     avatar: "https://...",
      #     avatar_static: "https://...",
      #     header: "https://...",
      #     header_static: "https://...",
      #     followers_count: 9528475,
      #     following_count: 72,
      #     statuses_count: 26249,
      #     last_status_at: "2025-04-10",
      #     verified: true,
      #     location: "",
      #     website: "www.DonaldJTrump.com",
      #     accepting_messages: false,
      #     chats_onboarded: true,
      #     feeds_onboarded: true,
      #     tv_onboarded: false,
      #     bookmarks_onboarded: false,
      #     show_nonmember_group_statuses: false,
      #     pleroma: { accepts_chat_messages: false },
      #     tv_account: false,
      #     receive_only_follow_mentions: false,
      #     emojis: [],
      #     fields: []
      #   }
      def profile(handle)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        get("/v1/truthsocial/profile", handle: handle)
      end

      # Get posts from a Truth Social user
      #
      # Retrieves posts from a public Truth Social user's profile. Note that as of 8/27/2025,
      # Truth Social only allows viewing public profile/posts of prominent users (like Trump
      # and Vance), requiring auth for everyone else.
      #
      # @param handle [String, nil] Truth Social username (required if user_id not provided)
      # @param user_id [String, nil] Truth Social user ID for faster response times
      #   (e.g., Trump's is "107780257626128497")
      # @param next_max_id [String, nil] Used to paginate to next page of results
      # @param trim [Boolean, nil] Set to true for a trimmed down version of the response
      # @return [Hash] Posts data including array of posts and pagination info
      # @raise [ArgumentError] If neither handle nor user_id is provided
      # @raise [BadRequestError] If the parameters are invalid
      # @raise [NotFoundError] If the user is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get posts by handle
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.truth_social.user_posts(handle: "realDonaldTrump")
      #   result[:posts].each { |post| puts post[:text] }
      #
      # @example Get posts by user_id for faster response
      #   result = client.truth_social.user_posts(user_id: "107780257626128497")
      #
      # @example Paginate through posts
      #   result = client.truth_social.user_posts(handle: "realDonaldTrump")
      #   next_page = client.truth_social.user_posts(
      #     handle: "realDonaldTrump",
      #     next_max_id: result[:next_max_id]
      #   )
      #
      # @example Get trimmed response
      #   result = client.truth_social.user_posts(handle: "realDonaldTrump", trim: true)
      #
      # @example Response structure
      #   {
      #     success: true,
      #     posts: [
      #       {
      #         text: "Post content...",
      #         id: "114315232218538121",
      #         created_at: "2025-04-10T19:06:55.053Z",
      #         content: "<p>HTML content...</p>",
      #         url: "https://truthsocial.com/@realDonaldTrump/114315232218538121",
      #         account: { username: "realDonaldTrump", display_name: "Donald J. Trump", ... },
      #         replies_count: 601,
      #         reblogs_count: 1607,
      #         favourites_count: 6282,
      #         media_attachments: [],
      #         card: { title: "...", description: "...", ... },
      #         ...
      #       }
      #     ],
      #     next_max_id: "114308258545250117"
      #   }
      def user_posts(handle: nil, user_id: nil, next_max_id: nil, trim: nil)
        if (handle.nil? || handle.to_s.empty?) && (user_id.nil? || user_id.to_s.empty?)
          raise ArgumentError, "handle or user_id is required"
        end

        params = {}
        params[:handle] = handle unless handle.nil? || handle.to_s.empty?
        params[:user_id] = user_id unless user_id.nil? || user_id.to_s.empty?
        params[:next_max_id] = next_max_id unless next_max_id.nil?
        params[:trim] = trim unless trim.nil?

        get("/v1/truthsocial/user/posts", params)
      end

      # Get a specific Truth Social post
      #
      # Retrieves detailed information about a specific Truth Social post (also known as a "Truth")
      # including the content, engagement metrics, media attachments, and author information.
      #
      # @param url [String] The full URL of the Truth Social post
      #   (e.g., "https://truthsocial.com/@realDonaldTrump/114315219437063160")
      # @return [Hash] Post data including content, account info, and engagement metrics
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the post is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Truth Social post
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   post = client.truth_social.post("https://truthsocial.com/@realDonaldTrump/114315219437063160")
      #   puts post[:text]             # => "It's so hard to watch as..."
      #   puts post[:replies_count]    # => 797
      #   puts post[:reblogs_count]    # => 2423
      #   puts post[:favourites_count] # => 8552
      #
      # @example Response structure
      #   {
      #     success: true,
      #     text: "Post text content...",
      #     id: "114315219437063160",
      #     created_at: "2025-04-10T19:03:40.023Z",
      #     in_reply_to_id: nil,
      #     quote_id: nil,
      #     sensitive: false,
      #     spoiler_text: "",
      #     visibility: "public",
      #     language: "en",
      #     uri: "https://truthsocial.com/@realDonaldTrump/114315219437063160",
      #     url: "https://truthsocial.com/@realDonaldTrump/114315219437063160",
      #     content: "<p>HTML content...</p>",
      #     account: {
      #       id: "107780257626128497",
      #       username: "realDonaldTrump",
      #       display_name: "Donald J. Trump",
      #       followers_count: 9528704,
      #       following_count: 72,
      #       statuses_count: 26249,
      #       verified: true,
      #       ...
      #     },
      #     media_attachments: [],
      #     mentions: [],
      #     tags: [],
      #     card: nil,
      #     replies_count: 797,
      #     reblogs_count: 2423,
      #     favourites_count: 8552,
      #     emojis: []
      #   }
      def post(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/truthsocial/post", url: url)
      end
    end
  end
end
