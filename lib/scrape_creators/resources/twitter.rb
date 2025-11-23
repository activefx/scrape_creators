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
    end
  end
end
