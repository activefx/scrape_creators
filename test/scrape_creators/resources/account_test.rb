# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Account do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:account) { client.account }

  describe "#credit_balance" do
    it "fetches credit balance successfully" do
      VCR.use_cassette("account/credit_balance_success") do
        result = account.credit_balance

        assert_kind_of Hash, result
        assert result.key?(:credit_count)
      end
    end

    it "returns credit_count as an integer" do
      VCR.use_cassette("account/credit_balance_success") do
        result = account.credit_balance

        assert_kind_of Integer, result[:credit_count]
      end
    end

    it "returns success flag" do
      VCR.use_cassette("account/credit_balance_success") do
        result = account.credit_balance

        assert result.key?(:success)
        assert_predicate result[:success], :itself
      end
    end
  end
end
