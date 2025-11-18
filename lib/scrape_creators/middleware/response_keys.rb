# frozen_string_literal: true

require "faraday"

module ScrapeCreators
  module Middleware
    # Faraday middleware to convert response keys from camelCase to snake_case
    #
    # This middleware automatically transforms all JSON response keys from
    # camelCase (as returned by the API) to snake_case (Ruby convention).
    #
    # @example
    #   # API returns: { "firstName": "John", "lastName": "Doe" }
    #   # Middleware transforms to: { first_name: "John", last_name: "Doe" }
    class ResponseKeys < Faraday::Middleware
      def on_complete(env)
        # Only process JSON responses
        return unless env[:response_headers]["content-type"]&.include?("application/json")

        # Only process if body is a hash (already parsed by json middleware)
        return unless env[:body].is_a?(Hash)

        # Transform all keys from camelCase to snake_case
        env[:body] = ScrapeCreators::Util.deep_transform_keys(env[:body])
      end
    end
  end
end

# Register the middleware with Faraday
Faraday::Response.register_middleware(
  response_keys: ScrapeCreators::Middleware::ResponseKeys
)
