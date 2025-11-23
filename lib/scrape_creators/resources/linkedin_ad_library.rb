# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # LinkedIn Ad Library API resource
    #
    # Provides methods to interact with LinkedIn Ad Library endpoints for searching
    # and retrieving ad information.
    #
    # @see https://docs.scrapecreators.com/v1/linkedin-ad-library LinkedIn Ad Library API Documentation
    class LinkedinAdLibrary < Resource
      # Search the LinkedIn Ad Library
      #
      # Searches for ads in the LinkedIn Ad Library based on various criteria.
      # At least one of company or keyword is required for the search.
      #
      # @param company [String, nil] The company name to search for (e.g., "Microsoft")
      # @param keyword [String, nil] The keyword to search for
      # @param countries [String, nil] Comma separated list of countries (e.g., "US,CA,MX")
      # @param start_date [String, nil] Start date to search for (format: YYYY-MM-DD)
      # @param end_date [String, nil] End date to search for (format: YYYY-MM-DD)
      # @param pagination_token [String, nil] Pagination token to paginate through results
      # @return [Hash] Response containing success status, ads array, pagination token, and is_last_page flag
      # @raise [ArgumentError] If neither company nor keyword is provided
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Search ads by company name
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.linkedin_ad_library.search(company: "Microsoft")
      #   result[:ads].each { |ad| puts ad[:description] }
      #
      # @example Search ads by keyword
      #   result = client.linkedin_ad_library.search(keyword: "software engineer")
      #
      # @example Search with country filter
      #   result = client.linkedin_ad_library.search(
      #     company: "Microsoft",
      #     countries: "US,CA"
      #   )
      #
      # @example Search with date range
      #   result = client.linkedin_ad_library.search(
      #     company: "Microsoft",
      #     start_date: "2024-01-01",
      #     end_date: "2024-12-31"
      #   )
      #
      # @example Paginate through results
      #   first_page = client.linkedin_ad_library.search(company: "Microsoft")
      #   unless first_page[:is_last_page]
      #     next_page = client.linkedin_ad_library.search(
      #       company: "Microsoft",
      #       pagination_token: first_page[:pagination_token]
      #     )
      #   end
      #
      # @example Response structure
      #   {
      #     success: true,
      #     ads: [
      #       {
      #         id: "823975056",
      #         description: "The countdown has begun...",
      #         headline: nil,
      #         poster: "Microsoft",
      #         poster_title: "Promoted",
      #         promoted_by: nil,
      #         targeting: {
      #           language: "Targeting includes English",
      #           location: "Targeting includes Netherlands",
      #           company: "Exclusion targeting applied"
      #         },
      #         image: "https://media.licdn.com/...",
      #         video: nil,
      #         carousel_images: [],
      #         ad_type: "Single Image Ad",
      #         advertiser: "Microsoft",
      #         advertiser_linkedin_page: "https://www.linkedin.com/company/1035",
      #         cta: nil,
      #         destination_url: "http://msft.it/...",
      #         ad_duration: "Ran from Aug 10, 2025 to Aug 10, 2025",
      #         start_date: "2025-08-10T05:00:00.000Z",
      #         end_date: "2025-08-10T05:00:00.000Z",
      #         total_impressions: "< 1k",
      #         impressions_by_country: []
      #       }
      #     ],
      #     pagination_token: "756412693-1754569518292",
      #     is_last_page: false
      #   }
      def search(company: nil, keyword: nil, **options)
        validate_search_params!(company, keyword)

        params = build_search_params(company, keyword, options)
        get("/v1/linkedin/ads/search", params)
      end

      private

      def validate_search_params!(company, keyword)
        raise ArgumentError, "company or keyword is required" if blank?(company) && blank?(keyword)
      end

      def build_search_params(company, keyword, options)
        params = {}
        params[:company] = company unless blank?(company)
        params[:keyword] = keyword unless blank?(keyword)
        params[:countries] = options[:countries] unless options[:countries].nil?
        params[:startDate] = options[:start_date] unless options[:start_date].nil?
        params[:endDate] = options[:end_date] unless options[:end_date].nil?
        params[:paginationToken] = options[:pagination_token] unless options[:pagination_token].nil?
        params
      end

      def blank?(value)
        value.nil? || value.to_s.empty?
      end
    end
  end
end
