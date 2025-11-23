# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Instagram API resource
    #
    # Provides methods to interact with Instagram endpoints for scraping public profile data,
    # posts, reels, comments, and more.
    #
    # @see https://docs.scrapecreators.com/v1/instagram Instagram API Documentation
    class Instagram < Resource
      # Get a public Instagram profile
      #
      # Scrapes a public Instagram profile including user information, recent posts,
      # bio links, and related accounts.
      #
      # @param handle [String] Instagram handle (username)
      # @param trim [Boolean, nil] Whether to trim the response data (default: false)
      # @return [Hash] Profile data including user info, posts, and related profiles
      # @raise [ArgumentError] If the handle parameter is nil or empty
      # @raise [BadRequestError] If the handle parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get an Instagram profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   profile = client.instagram.profile("adrianhorning")
      #   puts profile[:data][:user][:full_name]  # => "Adrian Horning"
      #   puts profile[:data][:user][:edge_followed_by][:count]  # => 25116
      #
      # @example Get a trimmed profile response
      #   profile = client.instagram.profile("adrianhorning", trim: true)
      #
      # @example Response structure
      #   {
      #     success: true,
      #     data: {
      #       user: {
      #         id: "2700692569",
      #         username: "adrianhorning",
      #         full_name: "Adrian Horning",
      #         biography: "Scraping the web",
      #         bio_links: [
      #           {
      #             title: "Social Media APIs",
      #             url: "https://scrapecreators.com",
      #             link_type: "external"
      #           }
      #         ],
      #         external_url: "https://scrapecreators.com/",
      #         edge_followed_by: { count: 25116 },
      #         edge_follow: { count: 101 },
      #         is_private: false,
      #         is_verified: true,
      #         is_business_account: true,
      #         profile_pic_url: "https://...",
      #         profile_pic_url_hd: "https://...",
      #         edge_owner_to_timeline_media: {
      #           count: 71,
      #           page_info: { has_next_page: true, end_cursor: "..." },
      #           edges: [
      #             {
      #               node: {
      #                 id: "3540614075954356349",
      #                 shortcode: "DEiyb48AeB9",
      #                 display_url: "https://...",
      #                 is_video: true,
      #                 edge_liked_by: { count: 126 },
      #                 edge_media_to_comment: { count: 12 }
      #               }
      #             }
      #           ]
      #         },
      #         edge_related_profiles: {
      #           edges: [
      #             {
      #               node: {
      #                 id: "66873381803",
      #                 username: "itsallykrinsky",
      #                 full_name: "ally"
      #               }
      #             }
      #           ]
      #         }
      #       }
      #     },
      #     status: "ok"
      #   }
      def profile(handle, trim: nil)
        raise ArgumentError, "handle is required" if handle.nil? || handle.to_s.empty?

        params = { handle: handle }
        params[:trim] = trim unless trim.nil?

        get("/v1/instagram/profile", params)
      end
    end
  end
end
