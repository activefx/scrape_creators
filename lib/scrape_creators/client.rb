# frozen_string_literal: true

require "faraday"
require "faraday/retry"
require "json"

module ScrapeCreators
  # HTTP client for the ScrapeCreators API
  #
  # Manages the Faraday connection and provides access to all API resources.
  #
  # @example
  #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
  #   profile = client.tiktok.profile("username")
  class Client
    # @return [String] API key for authentication
    attr_reader :api_key

    # @return [Hash] Configuration options
    attr_reader :config

    # Initialize a new client
    #
    # @param api_key [String, nil] API key (defaults to global configuration)
    # @param options [Hash] Additional configuration options
    # @option options [String] :base_url Base URL for the API
    # @option options [Integer] :timeout Request timeout in seconds
    # @option options [Boolean] :debug Enable debug logging
    # @option options [Integer] :max_retries Maximum number of retries
    # @option options [Integer] :retry_interval Retry interval in seconds
    def initialize(api_key: nil, **options)
      @api_key = api_key || ScrapeCreators.configuration&.api_key
      raise ArgumentError, "API key is required" if @api_key.nil? || @api_key.empty?

      # Start with default configuration values
      default_config = Configuration.new.to_h
      # Merge with global configuration if available
      global_config = ScrapeCreators.configuration.to_h
      # Merge with instance-specific options
      @config = default_config.merge(global_config).merge(options)
      @config[:api_key] = @api_key
    end

    # Get the Faraday connection
    #
    # @return [Faraday::Connection]
    def connection
      @connection ||= Faraday.new(url: config[:base_url]) do |conn|
        # Request middleware
        conn.request :json
        conn.request :retry,
                     max: config[:max_retries] || 3,
                     interval: config[:retry_interval] || 1,
                     backoff_factor: 2,
                     retry_statuses: [429, 500, 502, 503, 504],
                     methods: %i[get post put delete]

        # Set headers
        conn.headers["x-api-key"] = api_key
        conn.headers["Content-Type"] = "application/json"
        conn.headers["Accept"] = "application/json"

        # Response middleware
        conn.response :json, content_type: /\bjson$/
        conn.response :logger if config[:debug]

        # HTTP adapter
        conn.adapter Faraday.default_adapter

        # Set timeout
        conn.options.timeout = config[:timeout] || 30
      end
    end

    # TikTok resource
    #
    # @return [Resources::Tiktok]
    def tiktok
      @tiktok ||= Resources::Tiktok.new(self)
    end

    # TikTok Shop resource
    #
    # @return [Resources::TiktokShop]
    def tiktok_shop
      @tiktok_shop ||= Resources::TiktokShop.new(self)
    end

    # Instagram resource
    #
    # @return [Resources::Instagram]
    def instagram
      @instagram ||= Resources::Instagram.new(self)
    end

    # YouTube resource
    #
    # @return [Resources::Youtube]
    def youtube
      @youtube ||= Resources::Youtube.new(self)
    end

    # LinkedIn resource
    #
    # @return [Resources::Linkedin]
    def linkedin
      @linkedin ||= Resources::Linkedin.new(self)
    end

    # Facebook resource
    #
    # @return [Resources::Facebook]
    def facebook
      @facebook ||= Resources::Facebook.new(self)
    end

    # Facebook Ad Library resource
    #
    # @return [Resources::FacebookAdLibrary]
    def facebook_ad_library
      @facebook_ad_library ||= Resources::FacebookAdLibrary.new(self)
    end

    # Google Ad Library resource
    #
    # @return [Resources::GoogleAdLibrary]
    def google_ad_library
      @google_ad_library ||= Resources::GoogleAdLibrary.new(self)
    end

    # LinkedIn Ad Library resource
    #
    # @return [Resources::LinkedinAdLibrary]
    def linkedin_ad_library
      @linkedin_ad_library ||= Resources::LinkedinAdLibrary.new(self)
    end

    # Twitter resource
    #
    # @return [Resources::Twitter]
    def twitter
      @twitter ||= Resources::Twitter.new(self)
    end

    # Reddit resource
    #
    # @return [Resources::Reddit]
    def reddit
      @reddit ||= Resources::Reddit.new(self)
    end

    # Truth Social resource
    #
    # @return [Resources::TruthSocial]
    def truth_social
      @truth_social ||= Resources::TruthSocial.new(self)
    end

    # Threads resource
    #
    # @return [Resources::Threads]
    def threads
      @threads ||= Resources::Threads.new(self)
    end

    # Bluesky resource
    #
    # @return [Resources::Bluesky]
    def bluesky
      @bluesky ||= Resources::Bluesky.new(self)
    end

    # Pinterest resource
    #
    # @return [Resources::Pinterest]
    def pinterest
      @pinterest ||= Resources::Pinterest.new(self)
    end

    # Google resource
    #
    # @return [Resources::Google]
    def google
      @google ||= Resources::Google.new(self)
    end

    # Twitch resource
    #
    # @return [Resources::Twitch]
    def twitch
      @twitch ||= Resources::Twitch.new(self)
    end

    # Kick resource
    #
    # @return [Resources::Kick]
    def kick
      @kick ||= Resources::Kick.new(self)
    end

    # Snapchat resource
    #
    # @return [Resources::Snapchat]
    def snapchat
      @snapchat ||= Resources::Snapchat.new(self)
    end

    # Linktree resource
    #
    # @return [Resources::Linktree]
    def linktree
      @linktree ||= Resources::Linktree.new(self)
    end

    # Komi resource
    #
    # @return [Resources::Komi]
    def komi
      @komi ||= Resources::Komi.new(self)
    end

    # Pillar resource
    #
    # @return [Resources::Pillar]
    def pillar
      @pillar ||= Resources::Pillar.new(self)
    end

    # Linkbio resource
    #
    # @return [Resources::Linkbio]
    def linkbio
      @linkbio ||= Resources::Linkbio.new(self)
    end

    # Amazon Shop resource
    #
    # @return [Resources::AmazonShop]
    def amazon_shop
      @amazon_shop ||= Resources::AmazonShop.new(self)
    end

    # Age and Gender detection resource
    #
    # @return [Resources::AgeGender]
    def age_gender
      @age_gender ||= Resources::AgeGender.new(self)
    end

    # Account resource (for credit balance, etc.)
    #
    # @return [Resources::Account]
    def account
      @account ||= Resources::Account.new(self)
    end
  end
end
