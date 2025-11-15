# frozen_string_literal: true

module ScrapeCreators
  # Base class for all API resources
  #
  # Provides common HTTP methods and error handling for API resources.
  class Resource
    # @return [Client] The client instance
    attr_reader :client

    # Initialize a new resource
    #
    # @param client [Client] The client instance
    def initialize(client)
      @client = client
    end

    private

    # Make a GET request
    #
    # @param path [String] The API endpoint path
    # @param params [Hash] Query parameters
    # @return [Hash] Parsed response body
    # @raise [Error] On API errors
    def get(path, params = {})
      response = client.connection.get(path) do |req|
        req.params = params
      end
      handle_response(response)
    end

    # Make a POST request
    #
    # @param path [String] The API endpoint path
    # @param body [Hash] Request body
    # @return [Hash] Parsed response body
    # @raise [Error] On API errors
    def post(path, body = {})
      response = client.connection.post(path) do |req|
        req.body = body
      end
      handle_response(response)
    end

    # Make a PUT request
    #
    # @param path [String] The API endpoint path
    # @param body [Hash] Request body
    # @return [Hash] Parsed response body
    # @raise [Error] On API errors
    def put(path, body = {})
      response = client.connection.put(path) do |req|
        req.body = body
      end
      handle_response(response)
    end

    # Make a DELETE request
    #
    # @param path [String] The API endpoint path
    # @return [Hash] Parsed response body
    # @raise [Error] On API errors
    def delete(path)
      response = client.connection.delete(path)
      handle_response(response)
    end

    # Handle API response and errors
    #
    # @param response [Faraday::Response] The HTTP response
    # @return [Hash] Parsed response body
    # @raise [Error] On API errors
    def handle_response(response)
      case response.status
      when 200..299
        parse_json(response.body)
      when 400
        raise BadRequestError.new(
          extract_error_message(response),
          response_body: parse_json(response.body)
        )
      when 401
        raise UnauthorizedError.new(
          extract_error_message(response) || "Invalid or missing API key",
          response_body: parse_json(response.body)
        )
      when 402
        raise PaymentRequiredError.new(
          extract_error_message(response) || "Payment required - please purchase more credits",
          response_body: parse_json(response.body)
        )
      when 404
        raise NotFoundError.new(
          extract_error_message(response) || "Resource not found",
          response_body: parse_json(response.body)
        )
      when 429
        retry_after = response.headers["Retry-After"]&.to_i
        raise RateLimitError.new(
          extract_error_message(response) || "Rate limit exceeded",
          retry_after: retry_after,
          response_body: parse_json(response.body)
        )
      when 500..599
        raise ServerError.new(
          extract_error_message(response) || "Server error: #{response.status}",
          status_code: response.status,
          response_body: parse_json(response.body)
        )
      else
        raise Error.new(
          "Unexpected response: #{response.status}",
          status_code: response.status,
          response_body: parse_json(response.body)
        )
      end
    end

    # Parse JSON response
    #
    # @param body [String, Hash, Array] Response body
    # @return [Hash, Array] Parsed JSON
    def parse_json(body)
      return {} if body.nil?
      return {} if body.respond_to?(:empty?) && body.empty?

      # If Faraday's JSON middleware already parsed it, return as-is
      # (but ensure symbol keys for Hashes)
      if body.is_a?(Hash)
        return body.transform_keys(&:to_sym)
      elsif body.is_a?(Array)
        return body
      end

      # Otherwise, parse the JSON string
      JSON.parse(body, symbolize_names: true)
    rescue JSON::ParserError
      { raw: body }
    end

    # Extract error message from response
    #
    # @param response [Faraday::Response] The HTTP response
    # @return [String, nil] Error message
    def extract_error_message(response)
      body = parse_json(response.body)
      body[:error] || body[:message] || body[:error_message]
    rescue StandardError
      nil
    end
  end
end
