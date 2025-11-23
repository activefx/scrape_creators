# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Pinterest API resource
    #
    # Provides methods to interact with Pinterest endpoints for searching pins,
    # fetching pin details, user boards, and board information.
    #
    # @see https://docs.scrapecreators.com/v1/pinterest Pinterest API Documentation
    class Pinterest < Resource
      # Search Pinterest for pins
      #
      # Searches Pinterest for pins matching the given query. Returns pin data
      # including images, descriptions, board information, and pinner details.
      # Supports pagination and optional response trimming.
      #
      # @param query [String] The search query (required)
      # @param cursor [String, nil] Pagination cursor from previous response to get more pins
      # @param trim [Boolean, nil] Whether to return a trimmed response (default: false)
      # @return [Hash] Search results including success status, pins array, and pagination cursor
      # @raise [ArgumentError] If the query parameter is nil or empty
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Search for pins
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.pinterest.search("italian recipes")
      #   results[:pins].each { |pin| puts pin[:description] }
      #
      # @example Paginate through search results
      #   first_page = client.pinterest.search("home decor")
      #   if first_page[:cursor]
      #     next_page = client.pinterest.search("home decor", cursor: first_page[:cursor])
      #   end
      #
      # @example Get trimmed response
      #   results = client.pinterest.search("fashion", trim: true)
      #
      # @example Response structure
      #   {
      #     success: true,
      #     pins: [
      #       {
      #         node_id: "UGluOjM3Mjk2MTIyNTY2MDUxNDQ=",
      #         url: "https://www.pinterest.com/pin/3729612256605144/",
      #         auto_alt_text: "a close up of a plate of food with meat",
      #         id: "3729612256605144",
      #         is_promoted: false,
      #         description: "Italian Pot Roast: A Hearty and Flavorful Recipe",
      #         title: "",
      #         images: {
      #           orig: {
      #             width: 1024,
      #             height: 1024,
      #             url: "https://i.pinimg.com/originals/..."
      #           }
      #         },
      #         link: "https://myauntyrecipes.com/...",
      #         domain: "myauntyrecipes.com",
      #         seo_alt_text: "a close up of a plate of food with meat",
      #         board: {
      #           node_id: "Qm9hcmQ6MzcyOTY4MDg4MDQyNzg2OA==",
      #           name: "Food",
      #           owner: { ... },
      #           pin_count: 423,
      #           url: "/csadak/food/"
      #         },
      #         grid_title: "Savory Italian Pot Roast",
      #         native_creator: nil,
      #         created_at: "Tue, 07 Jan 2025 18:23:09 +0000",
      #         pinner: {
      #           node_id: "VXNlcjozNzI5NzQ5NTk5ODUyNTc1",
      #           full_name: "Courtney Elizabeth",
      #           follower_count: 85,
      #           username: "csadak"
      #         },
      #         videos: nil,
      #         story_pin_data: nil
      #       }
      #     ],
      #     cursor: "Y2JVSG81V2..."
      #   }
      def search(query, cursor: nil, trim: nil)
        raise ArgumentError, "query is required" if query.nil? || query.to_s.empty?

        params = { query: query }
        params[:cursor] = cursor unless cursor.nil?
        params[:trim] = trim unless trim.nil?

        get("/v1/pinterest/search", params)
      end
    end
  end
end
