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
    end
  end
end
