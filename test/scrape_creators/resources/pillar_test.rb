# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Pillar do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:pillar) { client.pillar }

  describe "#page" do
    let(:pillar_url) { "https://mypillar.io/angelstrife" }

    it "fetches Pillar page successfully" do
      VCR.use_cassette("pillar/page_success") do
        result = pillar.page(pillar_url)

        assert_kind_of Hash, result
        assert result.key?(:success)
        assert result[:success]
      end
    end

    it "returns expected profile fields" do
      VCR.use_cassette("pillar/page_success") do
        result = pillar.page(pillar_url)

        assert result.key?(:id)
        assert result.key?(:first_name)
        assert result.key?(:last_name)
        assert result.key?(:location)
      end
    end

    it "returns email information" do
      VCR.use_cassette("pillar/page_success") do
        result = pillar.page(pillar_url)

        assert result.key?(:email) || result.key?(:email_primary)
      end
    end

    it "returns social media links" do
      VCR.use_cassette("pillar/page_success") do
        result = pillar.page(pillar_url)

        # Check for social media platform links
        social_platforms = %i[instagram tiktok twitter youtube facebook linkedin spotify soundcloud]
        has_social_link = social_platforms.any? { |platform| result.key?(platform) }

        assert has_social_link, "Expected at least one social media link"
      end
    end

    it "returns links array with expected fields" do
      VCR.use_cassette("pillar/page_success") do
        result = pillar.page(pillar_url)

        assert result.key?(:links)
        assert_kind_of Array, result[:links]

        if result[:links].any?
          link = result[:links].first

          assert link.key?(:id)
          assert link.key?(:type)
          assert link.key?(:title)
          assert link.key?(:url)
        end
      end
    end

    it "returns products array when available" do
      VCR.use_cassette("pillar/page_success") do
        result = pillar.page(pillar_url)

        assert result.key?(:products)
        assert_kind_of Array, result[:products]

        if result[:products].any?
          product = result[:products].first

          assert product.key?(:id)
          assert product.key?(:title)
          assert product.key?(:price)
        end
      end
    end

    describe "argument validation" do
      it "raises ArgumentError when url is nil" do
        error = assert_raises(ArgumentError) do
          pillar.page(nil)
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is empty" do
        error = assert_raises(ArgumentError) do
          pillar.page("")
        end
        assert_match(/url is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises PaymentRequiredError for invalid API key" do
        VCR.use_cassette("pillar/page_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::PaymentRequiredError) do
            invalid_client.pillar.page(pillar_url)
          end

          assert_match(/credits/i, error.message)
        end
      end
    end
  end
end
