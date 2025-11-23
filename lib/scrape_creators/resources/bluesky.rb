# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Bluesky API resource
    #
    # Provides methods to interact with Bluesky endpoints for scraping public profile data
    # and posts.
    #
    # @see https://docs.scrapecreators.com/bluesky Bluesky API Documentation
    class Bluesky < Resource
      # Get a public Bluesky profile
      #
      # Retrieves public profile information for a Bluesky user including display name,
      # description, avatar, follower/following counts, verification status, and more.
      #
      # @param handle [String] Bluesky handle (e.g., "espn.com", "user.bsky.social")
      # @return [Hash] Profile data including user info and counts
      # @raise [ArgumentError] If the handle parameter is nil or empty
      # @raise [BadRequestError] If the handle parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Bluesky profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   profile = client.bluesky.profile("espn.com")
      #   puts profile[:handle]          # => "espn.com"
      #   puts profile[:display_name]    # => "ESPN"
      #   puts profile[:followers_count] # => 198477
      #
      # @example Response structure
      #   {
      #     success: true,
      #     did: "did:plc:x7d6j54pm22ufehkes6jo4jf",
      #     handle: "espn.com",
      #     display_name: "ESPN",
      #     avatar: "https://cdn.bsky.app/img/avatar/plain/...",
      #     associated: {
      #       lists: 0,
      #       feedgens: 0,
      #       starter_packs: 0,
      #       labeler: false
      #     },
      #     labels: [],
      #     created_at: "2024-11-25T21:49:49.345Z",
      #     verification: {
      #       verifications: [
      #         {
      #           issuer: "did:plc:z72i7hdynmk6r22z27h6tvur",
      #           uri: "at://did:plc:z72i7hdynmk6r22z27h6tvur/...",
      #           is_valid: true,
      #           created_at: "2025-04-21T10:44:20.398Z"
      #         }
      #       ],
      #       verified_status: "valid",
      #       trusted_verifier_status: "none"
      #     },
      #     description: "Serving sports fans. Anytime. Anywhere.",
      #     indexed_at: "2024-12-19T20:49:48.843Z",
      #     followers_count: 198477,
      #     follows_count: 32,
      #     posts_count: 659
      #   }
      def profile(handle)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        get("/bluesky/profile", handle: handle)
      end

      # Get posts from a Bluesky user
      #
      # Retrieves posts from a public Bluesky user's profile. Use user_id for faster
      # response times.
      #
      # @param handle [String, nil] Bluesky handle (e.g., "espn.com", "user.bsky.social")
      # @param user_id [String, nil] Bluesky DID (e.g., "did:plc:x7d6j54pm22ufehkes6jo4jf")
      # @param cursor [String, nil] Pagination cursor for fetching more posts
      # @return [Hash] Posts data including feed array and pagination cursor
      # @raise [ArgumentError] If both handle and user_id are nil or empty
      # @raise [BadRequestError] If the parameters are invalid
      # @raise [NotFoundError] If the user is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get posts by handle
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   response = client.bluesky.user_posts(handle: "espn.com")
      #   response[:feed].each do |post|
      #     puts post[:record][:text]
      #     puts "Likes: #{post[:like_count]}"
      #   end
      #
      # @example Get posts by user_id (faster)
      #   response = client.bluesky.user_posts(user_id: "did:plc:x7d6j54pm22ufehkes6jo4jf")
      #
      # @example Paginate through posts
      #   response = client.bluesky.user_posts(handle: "espn.com")
      #   while response[:cursor]
      #     response = client.bluesky.user_posts(handle: "espn.com", cursor: response[:cursor])
      #   end
      #
      # @example Response structure
      #   {
      #     success: true,
      #     feed: [
      #       {
      #         uri: "at://did:plc:x7d6j54pm22ufehkes6jo4jf/app.bsky.feed.post/...",
      #         cid: "bafyreibams5wyqdpg2cmmks7lhf5ccxu7hbu24sfatgc53jmb2nun5k5dm",
      #         author: {
      #           did: "did:plc:x7d6j54pm22ufehkes6jo4jf",
      #           handle: "espn.com",
      #           display_name: "ESPN",
      #           avatar: "https://cdn.bsky.app/img/avatar/plain/...",
      #           verification: { verified_status: "valid", ... }
      #         },
      #         record: {
      #           type: "app.bsky.feed.post",
      #           text: "Post content here...",
      #           created_at: "2025-05-29T19:01:20.743Z"
      #         },
      #         reply_count: 1,
      #         repost_count: 0,
      #         like_count: 24,
      #         quote_count: 1,
      #         indexed_at: "2025-05-29T19:01:21.645Z"
      #       }
      #     ],
      #     cursor: "2025-05-22T17:02:02.847Z"
      #   }
      def user_posts(handle: nil, user_id: nil, cursor: nil)
        if (handle.nil? || handle.to_s.empty?) && (user_id.nil? || user_id.to_s.empty?)
          raise ArgumentError, "handle or user_id is required"
        end

        params = {}
        params[:handle] = handle if handle && !handle.to_s.empty?
        params[:user_id] = user_id if user_id && !user_id.to_s.empty?
        params[:cursor] = cursor if cursor && !cursor.to_s.empty?

        get("/bluesky/user/posts", params)
      end

      # Get a Bluesky post
      #
      # Retrieves a single Bluesky post including author information, content,
      # engagement metrics, embeds, and replies.
      #
      # @param url [String] Bluesky post URL (e.g., "https://bsky.app/profile/espn.com/post/3lqdfq7fkvm2g")
      # @return [Hash] Post data including author, content, engagement metrics, and replies
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the post is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Bluesky post
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   response = client.bluesky.post("https://bsky.app/profile/espn.com/post/3lqdfq7fkvm2g")
      #   puts response[:post][:record][:text]
      #   puts "Likes: #{response[:post][:like_count]}"
      #
      # @example Response structure
      #   {
      #     success: true,
      #     post: {
      #       uri: "at://did:plc:x7d6j54pm22ufehkes6jo4jf/app.bsky.feed.post/3lqdfq7fkvm2g",
      #       cid: "bafyreibams5wyqdpg2cmmks7lhf5ccxu7hbu24sfatgc53jmb2nun5k5dm",
      #       author: {
      #         did: "did:plc:x7d6j54pm22ufehkes6jo4jf",
      #         handle: "espn.com",
      #         display_name: "ESPN",
      #         avatar: "https://cdn.bsky.app/img/avatar/plain/...",
      #         verification: { verified_status: "valid", ... }
      #       },
      #       record: {
      #         type: "app.bsky.feed.post",
      #         text: "Post content here...",
      #         created_at: "2025-05-29T19:01:20.743Z",
      #         embed: { ... }
      #       },
      #       embed: {
      #         type: "app.bsky.embed.external#view",
      #         external: {
      #           uri: "http://example.com",
      #           title: "Article Title",
      #           description: "Article description",
      #           thumb: "https://cdn.bsky.app/img/..."
      #         }
      #       },
      #       reply_count: 1,
      #       repost_count: 0,
      #       like_count: 24,
      #       quote_count: 1,
      #       indexed_at: "2025-05-29T19:01:21.645Z",
      #       labels: []
      #     },
      #     replies: [
      #       {
      #         type: "app.bsky.feed.defs#threadViewPost",
      #         post: {
      #           uri: "at://...",
      #           author: { ... },
      #           record: { text: "Reply content...", ... },
      #           like_count: 0,
      #           ...
      #         },
      #         replies: []
      #       }
      #     ]
      #   }
      def post(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/bluesky/post", url: url)
      end
    end
  end
end
