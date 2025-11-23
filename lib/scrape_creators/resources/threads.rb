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
    end
  end
end
