# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem

# Ignore errors.rb since we manually require it to define error classes at module level
loader.ignore("#{__dir__}/scrape_creators/errors.rb")
# Ignore middleware directory since it contains Faraday middleware
loader.ignore("#{__dir__}/scrape_creators/middleware")

loader.setup

# Manually require errors to define all error classes
require_relative "scrape_creators/errors"
# Manually require utility module
require_relative "scrape_creators/util"
# Manually require middleware
require_relative "scrape_creators/middleware/response_keys"

# Ruby client library for the ScrapeCreators API
#
# Provides a clean, idiomatic Ruby interface for interacting with the ScrapeCreators REST API,
# which provides social media data extraction capabilities.
#
# @example Basic usage
#   ScrapeCreators.configure do |config|
#     config.api_key = "your_api_key"
#     config.base_url = "https://api.scrapecreators.com"
#   end
#
#   client = ScrapeCreators::Client.new
#   creators = client.creators.list
#
# @see https://docs.scrapecreators.com/introduction ScrapeCreators API Documentation
module ScrapeCreators
  class << self
    # Configuration accessor
    attr_accessor :configuration

    # Configure the gem
    #
    # @yield [Configuration] configuration object
    # @return [Configuration] configuration object
    #
    # @example
    #   ScrapeCreators.configure do |config|
    #     config.api_key = "your_api_key"
    #     config.base_url = "https://api.scrapecreators.com"
    #   end
    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
      configuration
    end
  end
end

# Eager load when not in development/test
loader.eager_load if ENV["EAGER_LOAD"] == "true"
