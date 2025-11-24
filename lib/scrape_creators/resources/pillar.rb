# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Pillar API resource
    #
    # Provides methods to interact with Pillar endpoints for retrieving
    # profile information, social links, and products from Pillar pages.
    #
    # @see https://docs.scrapecreators.com/v1/pillar Pillar API Documentation
    class Pillar < Resource
      # Get Pillar page details
      #
      # Retrieves profile information including name, location, social links,
      # configured link items, and products from a Pillar page.
      #
      # @param url [String] Full URL to the Pillar page
      # @return [Hash] Pillar page data including profile, links, and products
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      # @raise [NotFoundError] If the Pillar page is not found
      #
      # @example Get a Pillar page
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.pillar.page("https://mypillar.io/angelstrife")
      #   puts "#{result[:first_name]} #{result[:last_name]}"
      #   result[:links].each { |link| puts "#{link[:title]}: #{link[:url]}" }
      #
      # @example Response structure
      #   {
      #     success: true,
      #     id: "d8a5cbb4-a64d-44f2-830d-27a489bbc608",
      #     first_name: "Angel",
      #     last_name: "Blanco",
      #     email_primary: "angelrafaelcovablanco@gmail.com",
      #     location: "México",
      #     email: "angelrafaelcovablanco@gmail.com",
      #     tiktok: "https://tiktok.com/@angelstrifeoficial",
      #     spotify: "https://open.spotify.com/artist/...",
      #     twitter: "https://twitter.com/SoyAngelStrife",
      #     youtube: "https://www.youtube.com/channel/...",
      #     facebook: "https://www.facebook.com/AngelStrifeOficial",
      #     linkedin: "https://mx.linkedin.com/in/angelcovablanco",
      #     instagram: "https://www.instagram.com/angelstrifeoficial",
      #     soundcloud: "https://soundcloud.com/contienda-records",
      #     links: [
      #       {
      #         id: "66472110-1ba7-11ee-b33b-e5396daf72e9",
      #         type: "twitter",
      #         title: "twitter",
      #         url: "https://twitter.com/SoyAngelStrife",
      #         clicks: 2,
      #         order: nil
      #       }
      #     ],
      #     products: [
      #       {
      #         id: "254c8681-1d52-11ee-b065-850167411bb1",
      #         title: "Album - LP",
      #         price: 0,
      #         url: "https://...",
      #         name: "Album - LP",
      #         description: "Special Edition",
      #         image: "https://..."
      #       }
      #     ]
      #   }
      def page(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/pillar", url: url)
      end
    end
  end
end
