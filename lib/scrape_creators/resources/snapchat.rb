# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Snapchat API resource
    #
    # Provides methods to interact with Snapchat endpoints for scraping public profile data
    # including user profiles, stories, highlights, and related accounts.
    #
    # @see https://docs.scrapecreators.com/v1/snapchat Snapchat API Documentation
    class Snapchat < Resource
      # Get a public Snapchat user profile
      #
      # Retrieves public profile information for a Snapchat user including
      # username, title, bio, subscriber count, profile picture, stories,
      # curated highlights, spotlight highlights, and related accounts.
      #
      # @param handle [String] Snapchat username/handle
      # @return [Hash] Profile data including user info, stories, and highlights
      # @raise [ArgumentError] If the handle parameter is nil or empty
      # @raise [BadRequestError] If the handle parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Snapchat profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   profile = client.snapchat.profile("zane")
      #   puts profile[:user_profile][:username]        # => "zane"
      #   puts profile[:user_profile][:title]           # => "Zane"
      #   puts profile[:user_profile][:subscriber_count] # => "1535700"
      #
      # @example Access profile details
      #   profile = client.snapchat.profile("zane")
      #   user = profile[:user_profile]
      #   puts user[:bio]                # => "Time to get buck wild baby"
      #   puts user[:profile_picture_url] # Profile picture URL
      #   puts user[:snapcode_image_url]  # Snapcode image URL
      #
      # @example Access related accounts
      #   profile = client.snapchat.profile("zane")
      #   profile[:user_profile][:related_accounts_info].each do |account|
      #     puts account[:public_profile_info][:username]
      #     puts account[:public_profile_info][:title]
      #   end
      #
      # @example Access curated highlights
      #   profile = client.snapchat.profile("zane")
      #   profile[:curated_highlights].each do |highlight|
      #     puts highlight[:story_title][:value]
      #     puts highlight[:thumbnail_url][:value]
      #   end
      #
      # @example Response structure
      #   {
      #     success: true,
      #     user_profile: {
      #       username: "zane",
      #       title: "Zane",
      #       snapcode_image_url: "https://app.snapchat.com/web/deeplink/snapcode?...",
      #       badge: 1,
      #       subscriber_count: "1535700",
      #       bio: "Time to get buck wild baby",
      #       profile_picture_url: "https://cf-st.sc-cdn.net/...",
      #       square_hero_image_url: "https://cf-st.sc-cdn.net/...",
      #       has_story: false,
      #       has_curated_highlights: true,
      #       has_spotlight_highlights: true,
      #       related_accounts_info: [...],
      #       creation_timestamp_ms: { value: "1584846804362" },
      #       last_update_timestamp_ms: { value: "1741518441231" },
      #       business_profile_id: "e123b268-312b-41d6-8088-b51c12c6f2c6"
      #     },
      #     story: null,
      #     curated_highlights: [...],
      #     spotlight_highlights: [...],
      #     spotlight_story_metadata: [...]
      #   }
      def profile(handle)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        get("/v1/snapchat/profile", handle: handle)
      end
    end
  end
end
