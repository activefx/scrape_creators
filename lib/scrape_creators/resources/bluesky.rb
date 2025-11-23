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
    end
  end
end
