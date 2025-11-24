# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Amazon Shop API resource
    #
    # Provides methods to interact with Amazon Shop endpoints for retrieving
    # products and details from creator Amazon Shop pages.
    #
    # @see https://docs.scrapecreators.com/v1/amazon/shop Amazon Shop API Documentation
    class AmazonShop < Resource
      # Get Amazon Shop page details
      #
      # Retrieves products and other details from a creator's Amazon Shop page.
      # Returns creator profile information, product lists, trending picks, and curations.
      #
      # @param url [String] Full URL to the Amazon Shop page (e.g., "https://www.amazon.com/shop/username")
      # @return [Hash] Amazon Shop page data including profile, lists, trending picks, and curations
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      # @raise [NotFoundError] If the Amazon Shop page is not found
      #
      # @example Get an Amazon Shop page
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.amazon_shop.page("https://www.amazon.com/shop/sydneydelrey")
      #   puts result[:name]
      #   result[:lists].each { |list| puts "#{list[:title]}: #{list[:item_count]} items" }
      #
      # @example Response structure
      #   {
      #     success: true,
      #     avatar: "https://m.media-amazon.com/images/I/...",
      #     name: "sydney del rey",
      #     description: "sharing all of my favorite Amazon finds...",
      #     socials: ["https://vm.tiktok.com/...", "https://www.youtube.com/..."],
      #     lists: [
      #       {
      #         title: "fall transition fits",
      #         item_count: 72,
      #         image: "https://m.media-amazon.com/images/...",
      #         url: "https://www.amazon.com/shop/sydneydelrey/list/..."
      #       }
      #     ],
      #     trending_picks: [
      #       {
      #         url: "https://www.amazon.com/shop/.../getProductDetails/...",
      #         image: "https://m.media-amazon.com/images/...",
      #         price: 9.99,
      #         discount: 29
      #       }
      #     ],
      #     curations: [
      #       {
      #         title: "Fall fashion",
      #         post_count: 93,
      #         image: "https://m.media-amazon.com/images/...",
      #         url: "https://www.amazon.com/shop/.../curation/..."
      #       }
      #     ],
      #     page_token: "amzn1.ideas..."
      #   }
      def page(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/amazon/shop", url: url)
      end
    end
  end
end
