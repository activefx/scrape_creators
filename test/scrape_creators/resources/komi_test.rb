# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Komi do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:komi) { client.komi }

  describe "#page" do
    let(:komi_url) { "https://komi.io/kimkardashian" }

    it "fetches Komi page successfully" do
      VCR.use_cassette("komi/page_success") do
        result = komi.page(komi_url)

        assert_kind_of Hash, result
        assert result.key?(:success)
        assert result[:success]
      end
    end

    it "returns expected profile fields" do
      VCR.use_cassette("komi/page_success") do
        result = komi.page(komi_url)

        assert result.key?(:id)
        assert result.key?(:username)
        assert result.key?(:avatar)
        assert result.key?(:display_name)
      end
    end

    it "returns name fields" do
      VCR.use_cassette("komi/page_success") do
        result = komi.page(komi_url)

        assert result.key?(:first_name)
        assert result.key?(:last_name)
        assert result.key?(:bio)
      end
    end

    it "returns social media links" do
      VCR.use_cassette("komi/page_success") do
        result = komi.page(komi_url)

        # Check for social media platform links
        social_keys = %i[instagram tiktok youtube twitter facebook snapchat website]
        has_social = social_keys.any? { |key| result.key?(key) }

        assert has_social, "Expected at least one social media link"
      end
    end

    it "returns links array" do
      VCR.use_cassette("komi/page_success") do
        result = komi.page(komi_url)

        assert result.key?(:links)
        assert_kind_of Array, result[:links]
      end
    end

    it "returns links with expected fields" do
      VCR.use_cassette("komi/page_success") do
        result = komi.page(komi_url)

        if result[:links].any?
          link = result[:links].first

          assert link.key?(:id)
          assert link.key?(:url)
          assert link.key?(:title)
          assert link.key?(:type)
        end
      end
    end

    describe "argument validation" do
      it "raises ArgumentError when url is nil" do
        error = assert_raises(ArgumentError) do
          komi.page(nil)
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is empty" do
        error = assert_raises(ArgumentError) do
          komi.page("")
        end
        assert_match(/url is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises PaymentRequiredError for invalid API key" do
        VCR.use_cassette("komi/page_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::PaymentRequiredError) do
            invalid_client.komi.page(komi_url)
          end

          assert_match(/credits/i, error.message)
        end
      end
    end
  end
end
