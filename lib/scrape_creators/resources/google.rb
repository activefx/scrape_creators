# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Google API resource
    #
    # Provides methods to interact with Google Search endpoints for searching the web.
    #
    # @see https://docs.scrapecreators.com/v1/google Google API Documentation
    class Google < Resource
      # Search Google
      #
      # Searches Google for results matching the given query. Supports filtering
      # by country/region to get localized results.
      #
      # @param query [String] The search query (required)
      # @param region [String, nil] 2 letter country code (e.g., US, UK, CA) to show results from that country
      # @return [Hash] Search results including success status and results array
      # @raise [ArgumentError] If the query parameter is nil or empty
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Search Google
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.google.search("Austen Allred")
      #   results[:results].each { |result| puts result[:title] }
      #
      # @example Search with region filter
      #   results = client.google.search("technology news", region: "UK")
      #
      # @example Response structure
      #   {
      #     success: true,
      #     results: [
      #       {
      #         url: "https://x.com/Austen",
      #         title: "Austen Allred ✓",
      #         description: "Among the dumbest assertions people make online..."
      #       },
      #       {
      #         url: "https://www.linkedin.com/in/austenallred",
      #         title: "Austen Allred - Gauntlet AI - LinkedIn",
      #         description: "Austen is a visionary CEO..."
      #       }
      #     ]
      #   }
      def search(query, region: nil)
        raise ArgumentError, "query is required" if query.nil? || query.to_s.empty?

        params = { query: query }
        params[:region] = region unless region.nil?

        get("/v1/google/search", params)
      end
    end
  end
end
