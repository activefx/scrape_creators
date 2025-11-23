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
    end
  end
end
