# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators do
  describe "module" do
    it "is defined" do
      assert defined?(ScrapeCreators)
    end

    it "has a version number" do
      refute_nil ScrapeCreators::VERSION
      assert_match(/\d+\.\d+\.\d+/, ScrapeCreators::VERSION)
    end
  end

  describe ".configure" do
    it "yields a configuration object" do
      config = nil
      ScrapeCreators.configure do |c|
        config = c
      end

      refute_nil config
    end

    it "returns the configuration object" do
      result = ScrapeCreators.configure

      assert_instance_of ScrapeCreators::Configuration, result
    end

    it "allows setting configuration options" do
      ScrapeCreators.configure do |config|
        config.api_key = "test_key"
      end

      assert_equal "test_key", ScrapeCreators.configuration.api_key
    end
  end
end
