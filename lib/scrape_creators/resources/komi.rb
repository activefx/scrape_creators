# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Komi API resource
    #
    # Provides methods to interact with Komi endpoints for retrieving
    # profile information and links from Komi pages.
    #
    # @see https://docs.scrapecreators.com/v1/komi Komi API Documentation
    class Komi < Resource
      # Get Komi page details
      #
      # Retrieves profile information and all links from a Komi page.
      # Returns user details including username, bio, display name, social links,
      # and all configured link items with their types (LINK, PRODUCT, etc.).
      #
      # @param url [String] Full URL to the Komi page (e.g., "https://komi.io/kimkardashian")
      # @return [Hash] Komi page data including profile and links
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      # @raise [NotFoundError] If the Komi page is not found
      #
      # @example Get a Komi page
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.komi.page("https://komi.io/kimkardashian")
      #   puts result[:display_name]
      #   result[:links].each { |link| puts "#{link[:title]}: #{link[:url]}" }
      #
      # @example Response structure
      #   {
      #     success: true,
      #     id: "64d82830-59aa-4488-bfb0-93426971d139",
      #     username: "kimkardashian",
      #     avatar: "https://komi-production-assets.s3.amazonaws.com/photos/...",
      #     bio: "",
      #     first_name: "Kim",
      #     last_name: "Kardashian",
      #     display_name: "Kim Kardashian",
      #     display_name_image: nil,
      #     instagram: "https://www.instagram.com/kimkardashian/",
      #     tiktok: "https://www.tiktok.com/@kimkardashian",
      #     youtube: "https://www.youtube.com/@KUWTK",
      #     twitter: "https://twitter.com/KimKardashian",
      #     facebook: "https://www.facebook.com/KimKardashian",
      #     snapchat: "https://www.snapchat.com/add/kimkardashian",
      #     website: nil,
      #     links: [
      #       {
      #         id: "6d7086df-ede4-4f8a-85e5-0fa410e60bc2",
      #         url: "https://skims.social/shop-skims",
      #         order: 0,
      #         title: "Visit SKIMS",
      #         visible: true,
      #         module_id: "e6ce39d2-e3df-4040-a5cc-ce016cacbc34",
      #         thumbnail: "https://komi-production-assets.s3-accelerate.amazonaws.com/...",
      #         version_id: "944094bf-f124-4b13-866a-3498c492736d",
      #         type: "LINK"
      #       }
      #     ]
      #   }
      def page(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/komi", url: url)
      end
    end
  end
end
