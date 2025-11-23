# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Twitter API resource
    #
    # Provides methods to interact with Twitter endpoints for scraping public profile data,
    # tweets, transcripts, and community information.
    #
    # @see https://docs.scrapecreators.com/v1/twitter Twitter API Documentation
    class Twitter < Resource
      # Get a Twitter profile
      #
      # Retrieves Twitter profile information including stats and metadata such as
      # follower counts, tweet counts, verification status, and profile details.
      #
      # @param handle [String] Twitter handle (username without @)
      # @return [Hash] Profile data including user info, stats, and verification details
      # @raise [ArgumentError] If the handle parameter is nil or empty
      # @raise [BadRequestError] If the handle parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Twitter profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   profile = client.twitter.profile("Austen")
      #   puts profile[:legacy][:name]           # => "Austen Allred"
      #   puts profile[:legacy][:followers_count] # => 377608
      #   puts profile[:is_blue_verified]        # => true
      #
      # @example Response structure
      #   {
      #     __typename: "User",
      #     id: "VXNlcjoyMjE4MzgzNDk=",
      #     rest_id: "221838349",
      #     affiliates_highlighted_label: {
      #       label: {
      #         url: { url: "https://twitter.com/bloomtech", url_type: "DeepLink" },
      #         badge: { url: "https://pbs.twimg.com/..." },
      #         description: "Bloom Institute of Technology",
      #         user_label_type: "BusinessLabel",
      #         user_label_display_type: "Badge"
      #       }
      #     },
      #     is_blue_verified: true,
      #     profile_image_shape: "Circle",
      #     legacy: {
      #       created_at: "Wed Dec 01 19:13:23 +0000 2010",
      #       description: "CEO https://t.co/...",
      #       favourites_count: 80812,
      #       followers_count: 377608,
      #       friends_count: 1051,
      #       listed_count: 3959,
      #       location: "Austin, TX",
      #       media_count: 3843,
      #       name: "Austen Allred",
      #       screen_name: "Austen",
      #       statuses_count: 46114,
      #       verified: false,
      #       profile_image_url_https: "https://pbs.twimg.com/...",
      #       profile_banner_url: "https://pbs.twimg.com/..."
      #     },
      #     verification_info: {
      #       is_identity_verified: false,
      #       reason: { description: { text: "..." } }
      #     },
      #     highlights_info: {
      #       can_highlight_tweets: true,
      #       highlighted_tweets: "482"
      #     },
      #     creator_subscriptions_count: 3
      #   }
      def profile(handle)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        get("/v1/twitter/profile", handle: handle)
      end

      # Get tweets from a user's profile
      #
      # Retrieves tweets from a Twitter user's profile. Note: Twitter publicly only returns
      # up to 100 of the user's most popular tweets, not their latest tweets.
      #
      # @param handle [String] Twitter handle (username without @)
      # @param trim [Boolean] Set to true for a trimmed down version of the response
      # @return [Hash] Hash containing tweets array with tweet data including content,
      #   engagement metrics, media, and user information
      # @raise [ArgumentError] If the handle parameter is nil or empty
      # @raise [BadRequestError] If the handle parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get tweets from a user's profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.twitter.user_tweets("adrian_horning_")
      #   result[:tweets].each do |tweet|
      #     puts tweet[:legacy][:full_text]
      #     puts "Likes: #{tweet[:legacy][:favorite_count]}"
      #     puts "Retweets: #{tweet[:legacy][:retweet_count]}"
      #   end
      #
      # @example Get trimmed tweets
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.twitter.user_tweets("adrian_horning_", trim: true)
      #
      # @example Response structure
      #   {
      #     tweets: [
      #       {
      #         __typename: "Tweet",
      #         rest_id: "1828402665845322123",
      #         core: {
      #           user_results: {
      #             result: {
      #               __typename: "User",
      #               id: "VXNlcjo0NTIwMjQxMjA5",
      #               rest_id: "4520241209",
      #               is_blue_verified: true,
      #               legacy: {
      #                 name: "Adrian | The Web Scraping Guy",
      #                 screen_name: "adrian_horning_",
      #                 followers_count: 17297
      #               }
      #             }
      #           }
      #         },
      #         views: {
      #           count: "493762",
      #           state: "EnabledWithCount"
      #         },
      #         legacy: {
      #           bookmark_count: 1030,
      #           created_at: "Tue Aug 27 12:02:20 +0000 2024",
      #           favorite_count: 1722,
      #           full_text: "I just scraped 2.8 million companies...",
      #           quote_count: 12,
      #           reply_count: 3186,
      #           retweet_count: 64
      #         },
      #         url: "https://x.com/Austen/status/1935730646267158797"
      #       }
      #     ]
      #   }
      def user_tweets(handle, trim: nil)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        params = { handle: handle }
        params[:trim] = trim unless trim.nil?

        get("/v1/twitter/user-tweets", params)
      end

      # Get detailed information about a specific tweet
      #
      # Retrieves tweet details including engagement metrics, user information,
      # media attachments, and view counts.
      #
      # @param url [String] The full URL of the tweet (e.g., "https://x.com/user/status/123")
      # @param trim [Boolean] Set to true for a trimmed down version of the response
      # @return [Hash] Tweet data including content, engagement metrics, user info, and media
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the tweet is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get tweet details
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   tweet = client.twitter.tweet("https://x.com/adrian_horning_/status/1628769691547074562")
      #   puts tweet[:legacy][:full_text]
      #   puts "Likes: #{tweet[:legacy][:favorite_count]}"
      #   puts "Retweets: #{tweet[:legacy][:retweet_count]}"
      #   puts "Views: #{tweet[:views][:count]}"
      #
      # @example Get trimmed tweet details
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   tweet = client.twitter.tweet("https://x.com/user/status/123", trim: true)
      #
      # @example Response structure
      #   {
      #     __typename: "Tweet",
      #     rest_id: "1628769691547074562",
      #     core: {
      #       user_results: {
      #         result: {
      #           __typename: "User",
      #           id: "VXNlcjo0NTIwMjQxMjA5",
      #           rest_id: "4520241209",
      #           is_blue_verified: true,
      #           legacy: {
      #             name: "Adrian | The Web Scraping Guy",
      #             screen_name: "adrian_horning_",
      #             followers_count: 16488
      #           }
      #         }
      #       }
      #     },
      #     views: {
      #       count: "101132",
      #       state: "EnabledWithCount"
      #     },
      #     legacy: {
      #       bookmark_count: 1159,
      #       created_at: "Thu Feb 23 14:52:10 +0000 2023",
      #       favorite_count: 402,
      #       full_text: "I've scraped huge retailers...",
      #       quote_count: 7,
      #       reply_count: 41,
      #       retweet_count: 30,
      #       id_str: "1628769691547074562"
      #     }
      #   }
      def tweet(url, trim: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:trim] = trim unless trim.nil?

        get("/v1/twitter/tweet", params)
      end

      # Get the transcript of a video tweet
      #
      # Retrieves an AI-generated transcript of the audio from a video tweet.
      # Note: This endpoint may be slower than others because it uses AI to
      # generate the transcript.
      #
      # @param url [String] The full URL of the video tweet (e.g., "https://x.com/user/status/123")
      # @return [Hash] Transcript data including success status and transcript text
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid or tweet has no video
      # @raise [NotFoundError] If the tweet is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get video tweet transcript
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.twitter.transcript("https://x.com/zaborovic/status/1855587637938598309")
      #   puts result[:success]     # => true
      #   puts result[:transcript]  # => "Since you're kind of like a leader..."
      #
      # @example Response structure
      #   {
      #     success: true,
      #     transcript: "Since you're kind of like a leader in innovation and technology..."
      #   }
      def transcript(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/twitter/tweet/transcript", url: url)
      end

      # Get the details of a Twitter(X) Community
      #
      # Retrieves community information including name, description, creator,
      # rules, member count, and member facepile.
      #
      # @param url [String] The full URL of the Twitter community
      #   (e.g., "https://x.com/i/communities/1926186499399139650")
      # @return [Hash] Community data including details, rules, and member info
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the community is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get community details
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   community = client.twitter.community("https://x.com/i/communities/1926186499399139650")
      #   puts community[:name]          # => "The First Thousand"
      #   puts community[:description]   # => "This community is for creators..."
      #   puts community[:member_count]  # => 1896
      #   puts community[:join_policy]   # => "Open"
      #
      # @example Access community rules
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   community = client.twitter.community("https://x.com/i/communities/1926186499399139650")
      #   community[:rules].each do |rule|
      #     puts "#{rule[:name]}: #{rule[:description]}"
      #   end
      #
      # @example Access community creator
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   community = client.twitter.community("https://x.com/i/communities/1926186499399139650")
      #   creator = community[:creator_results][:result]
      #   puts creator[:core][:screen_name]  # => "CanaCarson"
      #   puts creator[:is_blue_verified]    # => true
      #
      # @example Response structure
      #   {
      #     success: true,
      #     __typename: "Community",
      #     is_member: false,
      #     name: "The First Thousand",
      #     role: "NonMember",
      #     rest_id: "1926186499399139650",
      #     actions: {
      #       join_action_result: { __typename: "CommunityJoinActionUnavailable" },
      #       id: "Q29tbXVuaXR5QWN0aW9uczoxOTI2MTg2NDk5Mzk5MTM5NjUw"
      #     },
      #     description: "This community is for creators and builders...",
      #     creator_results: {
      #       result: {
      #         __typename: "User",
      #         id: "VXNlcjoxOTIxMzY4NDU0NDQ5MjAxMTUy",
      #         is_blue_verified: true,
      #         core: { screen_name: "CanaCarson" },
      #         verification: { verified: false }
      #       },
      #       id: "VXNlclJlc3VsdHM6MTkyMTM2ODQ1NDQ0OTIwMTE1Mg=="
      #     },
      #     join_policy: "Open",
      #     created_at: 1748073622931,
      #     rules: [
      #       {
      #         rest_id: "1926189963793609186",
      #         description: "This isn't the space to drop ChatGPT...",
      #         name: "No Empty Platitudes",
      #         id: "Q29tbXVuaXR5UnVsZToxOTI2MTg5OTYzNzkzNjA5MTg2"
      #       }
      #     ],
      #     members_facepile_results: [
      #       {
      #         result: {
      #           __typename: "User",
      #           avatar: { image_url: "https://pbs.twimg.com/..." },
      #           id: "VXNlcjoxOTIxMzY4NDU0NDQ5MjAxMTUy"
      #         },
      #         id: "VXNlclJlc3VsdHM6MTkyMTM2ODQ1NDQ0OTIwMTE1Mg=="
      #       }
      #     ],
      #     member_count: 1896,
      #     id: "Q29tbXVuaXR5OjE5MjYxODY0OTkzOTkxMzk2NTA="
      #   }
      def community(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/twitter/community", url: url)
      end

      # Get tweets from a Twitter(X) Community
      #
      # Retrieves tweets posted in a Twitter community, including tweet content,
      # engagement metrics, media, and user information for each tweet author.
      #
      # @param url [String] The full URL of the Twitter community
      #   (e.g., "https://x.com/i/communities/1926186499399139650")
      # @return [Hash] Hash containing success status and tweets array
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the community is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get community tweets
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.twitter.community_tweets("https://x.com/i/communities/1926186499399139650")
      #   result[:tweets].each do |tweet|
      #     puts tweet[:full_text]
      #     puts "Likes: #{tweet[:favorite_count]}"
      #     puts "Retweets: #{tweet[:retweet_count]}"
      #   end
      #
      # @example Access tweet author information
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.twitter.community_tweets("https://x.com/i/communities/1926186499399139650")
      #   tweet = result[:tweets].first
      #   user = tweet[:user]
      #   puts user[:core][:name]          # => "Mike in' Software"
      #   puts user[:core][:screen_name]   # => "mikeinsoftware"
      #   puts user[:is_blue_verified]     # => true
      #
      # @example Response structure
      #   {
      #     success: true,
      #     tweets: [
      #       {
      #         id: "1940874916771123735",
      #         source: "<a href=\"http://twitter.com/download/iphone\">Twitter for iPhone</a>",
      #         view_count: "8660",
      #         bookmark_count: 10,
      #         bookmarked: false,
      #         created_at: "Thu Jul 03 20:46:54 +0000 2025",
      #         conversation_id_str: "1940874916771123735",
      #         display_text_range: [0, 27],
      #         favorite_count: 173,
      #         favorited: false,
      #         full_text: "You just need 1 viral tweet https://t.co/Z4Q5jtsxAp",
      #         is_quote_status: false,
      #         lang: "en",
      #         possibly_sensitive: false,
      #         quote_count: 2,
      #         reply_count: 55,
      #         retweet_count: 3,
      #         retweeted: false,
      #         user_id_str: "73647967",
      #         id_str: "1940874916771123735",
      #         user: {
      #           __typename: "User",
      #           id: "VXNlcjo3MzY0Nzk2Nw==",
      #           rest_id: "73647967",
      #           is_blue_verified: true,
      #           core: {
      #             created_at: "Sat Sep 12 14:00:05 +0000 2009",
      #             name: "Mike in' Software",
      #             screen_name: "mikeinsoftware"
      #           },
      #           legacy: {
      #             description: "Senior SWE👨‍💻 Indie hacking...",
      #             followers_count: 1173,
      #             friends_count: 990,
      #             statuses_count: 2931
      #           }
      #         }
      #       }
      #     ]
      #   }
      def community_tweets(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/twitter/community/tweets", url: url)
      end
    end
  end
end
