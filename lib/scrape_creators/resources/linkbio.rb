# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Linkbio (lnk.bio) API resource
    #
    # Provides methods to interact with Linkbio endpoints for retrieving
    # profile information and links from lnk.bio pages.
    #
    # @see https://docs.scrapecreators.com/v1/linkbio Linkbio API Documentation
    class Linkbio < Resource
      # Get Linkbio page details
      #
      # Retrieves profile information and all links from a Linkbio (lnk.bio) page.
      # Returns user details including handle, id, social media links,
      # and all configured link items.
      #
      # @param url [String] Full URL to the Linkbio page (e.g., "https://lnk.bio/msjennafischer")
      # @return [Hash] Linkbio page data including profile and links
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      # @raise [NotFoundError] If the Linkbio page is not found
      #
      # @example Get a Linkbio page
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.linkbio.page("https://lnk.bio/msjennafischer")
      #   puts result[:handle]
      #   result[:links].each { |link| puts "#{link[:text]}: #{link[:url]}" }
      #
      # @example Response structure
      #   {
      #     success: true,
      #     handle: "msjennafischer",
      #     id: "-1154992",
      #     instagram: nil,
      #     email: nil,
      #     tiktok: nil,
      #     youtube: nil,
      #     twitter: nil,
      #     whatsapp: nil,
      #     website: nil,
      #     links: [
      #       {
      #         url: "https://www.instagram.com/msjennafischer",
      #         text: "@msjennafischer"
      #       },
      #       {
      #         url: "https://officeladies.com/episodes",
      #         text: "Office Ladies Podcast"
      #       }
      #     ]
      #   }
      def page(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/linkbio", url: url)
      end
    end
  end
end
