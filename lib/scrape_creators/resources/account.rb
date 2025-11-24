# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Account API resource
    #
    # Provides methods to interact with account-related endpoints such as
    # retrieving credit balance information.
    #
    # @see https://docs.scrapecreators.com/v1/credit-balance Credit Balance API Documentation
    class Account < Resource
      # Get credit balance
      #
      # Retrieves the current credit balance for your account. This shows
      # how many API credits you have remaining.
      #
      # @return [Hash] Credit balance data including :credit_count
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [ServerError] If the server encounters an error
      #
      # @example Get credit balance
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.account.credit_balance
      #   puts "You have #{result[:credit_count]} credits remaining"
      #
      # @example Response structure
      #   {
      #     credit_count: 333
      #   }
      def credit_balance
        get("/v1/credit-balance")
      end
    end
  end
end
