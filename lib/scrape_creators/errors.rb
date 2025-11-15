# frozen_string_literal: true

module ScrapeCreators
  # Base error class for all ScrapeCreators errors
  class Error < StandardError
    # @return [Integer, nil] HTTP status code if applicable
    attr_reader :status_code

    # @return [Hash, nil] Response body if applicable
    attr_reader :response_body

    # Initialize a new error
    #
    # @param message [String] Error message
    # @param status_code [Integer, nil] HTTP status code
    # @param response_body [Hash, nil] Response body
    def initialize(message = nil, status_code: nil, response_body: nil)
      super(message)
      @status_code = status_code
      @response_body = response_body
    end
  end

  # Raised when the API key is missing or invalid (401)
  class UnauthorizedError < Error
    def initialize(message = "Invalid or missing API key", **)
      super(message, status_code: 401, **)
    end
  end

  # Raised when the request parameters are invalid (400)
  class BadRequestError < Error
    def initialize(message = "Bad request - invalid parameters or missing required fields", **)
      super(message, status_code: 400, **)
    end
  end

  # Raised when payment is required (402)
  class PaymentRequiredError < Error
    def initialize(message = "Payment required - please purchase more credits", **)
      super(message, status_code: 402, **)
    end
  end

  # Raised when a resource is not found (404)
  class NotFoundError < Error
    def initialize(message = "Resource not found", **)
      super(message, status_code: 404, **)
    end
  end

  # Raised when rate limit is exceeded (429)
  class RateLimitError < Error
    # @return [Integer, nil] Number of seconds to wait before retrying
    attr_reader :retry_after

    def initialize(message = "Rate limit exceeded", retry_after: nil, **)
      super(message, status_code: 429, **)
      @retry_after = retry_after
    end
  end

  # Raised when the server returns an error (500+)
  class ServerError < Error
    def initialize(message = "Server error - please try again later", **)
      super(message, status_code: 500, **)
    end
  end

  # Raised when there's a network or connection error
  class ConnectionError < Error; end

  # Raised when a request times out
  class TimeoutError < Error; end
end
