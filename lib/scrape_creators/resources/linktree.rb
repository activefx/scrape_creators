# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Linktree API resource
    #
    # Provides methods to interact with Linktree endpoints for retrieving
    # profile information and links from Linktree pages.
    #
    # @see https://docs.scrapecreators.com/v1/linktree Linktree API Documentation
    class Linktree < Resource
      # Get Linktree page details
      #
      # Retrieves profile information and all links from a Linktree page.
      # Returns user details including username, description, social links,
      # and all configured link items.
      #
      # @param url [String] Full URL to the Linktree page (e.g., "https://linktr.ee/username")
      # @return [Hash] Linktree page data including profile and links
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      # @raise [NotFoundError] If the Linktree page is not found
      #
      # @example Get a Linktree page
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.linktree.page("https://linktr.ee/miguelangeles")
      #   puts result[:username]
      #   result[:links].each { |link| puts "#{link[:title]}: #{link[:url]}" }
      #
      # @example Response structure
      #   {
      #     success: true,
      #     id: 15278008,
      #     username: "miguelangeles",
      #     profile_picture_url: "https://ugc.production.linktr.ee/...",
      #     description: "☆☆☆☆ IRL ANGEL ☆☆☆☆\nψ EMBRACE CHAOS ψ",
      #     verticals: ["music", "creative", "arts-entertainment"],
      #     link_platforms: ["Instagram", "TikTok"],
      #     timezone: "America/New_York",
      #     links: [
      #       {
      #         id: 463416775,
      #         type: "SPOTIFY_ALBUM",
      #         title: "new project...",
      #         url: "https://open.spotify.com/album/..."
      #       }
      #     ],
      #     instagram: "https://instagram.com/miguelangeles",
      #     tiktok: "https://tiktok.com/@irlangel",
      #     spotify: "https://open.spotify.com/artist/...",
      #     youtube: "https://www.youtube.com/watch?v=...",
      #     soundcloud: "https://soundcloud.com/miguelangeles",
      #     apple_music: "https://music.apple.com/ca/artist/...",
      #     email_address: "miguel@irlangel.com"
      #   }
      def page(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/linktree", url: url)
      end
    end
  end
end
