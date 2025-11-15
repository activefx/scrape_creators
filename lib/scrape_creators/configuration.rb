# frozen_string_literal: true

module ScrapeCreators
  # Configuration class for ScrapeCreators gem
  #
  # @example
  #   ScrapeCreators.configure do |config|
  #     config.api_key = "your_api_key"
  #     config.base_url = "https://api.scrapecreators.com"
  #     config.timeout = 30
  #   end
  class Configuration
    # @return [String] API key for ScrapeCreators API
    attr_accessor :api_key

    # @return [String] Base URL for ScrapeCreators API
    attr_accessor :base_url

    # @return [Integer] Request timeout in seconds
    attr_accessor :timeout

    # @return [Boolean] Enable debug logging
    attr_accessor :debug

    # @return [Integer] Maximum number of retries
    attr_accessor :max_retries

    # @return [Integer] Retry interval in seconds
    attr_accessor :retry_interval

    # Initialize a new Configuration instance with default values
    def initialize
      @base_url = "https://api.scrapecreators.com"
      @timeout = 30
      @debug = false
      @max_retries = 3
      @retry_interval = 1
    end

    # Merge configuration options
    #
    # @param options [Hash] Options to merge
    # @return [Hash] Merged configuration
    def merge(options = {})
      {
        api_key: options[:api_key] || api_key,
        base_url: options[:base_url] || base_url,
        timeout: options[:timeout] || timeout,
        debug: options.key?(:debug) ? options[:debug] : debug,
        max_retries: options[:max_retries] || max_retries,
        retry_interval: options[:retry_interval] || retry_interval
      }
    end

    # Convert configuration to hash
    #
    # @return [Hash] Configuration as hash
    def to_h
      {
        api_key: api_key,
        base_url: base_url,
        timeout: timeout,
        debug: debug,
        max_retries: max_retries,
        retry_interval: retry_interval
      }
    end
  end
end
