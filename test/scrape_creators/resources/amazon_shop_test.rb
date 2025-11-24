# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::AmazonShop do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:amazon_shop) { client.amazon_shop }

  describe "#page" do
    let(:shop_url) { "https://www.amazon.com/shop/sydneydelrey" }

    it "fetches Amazon Shop page successfully" do
      VCR.use_cassette("amazon_shop/page_success") do
        result = amazon_shop.page(shop_url)

        assert_kind_of Hash, result
        assert result.key?(:success)
        assert result[:success]
      end
    end

    it "returns expected profile fields" do
      VCR.use_cassette("amazon_shop/page_success") do
        result = amazon_shop.page(shop_url)

        assert result.key?(:avatar)
        assert result.key?(:name)
        assert result.key?(:description)
      end
    end

    it "returns social media links array" do
      VCR.use_cassette("amazon_shop/page_success") do
        result = amazon_shop.page(shop_url)

        assert result.key?(:socials)
        assert_kind_of Array, result[:socials]
      end
    end

    it "returns lists array with expected fields" do
      VCR.use_cassette("amazon_shop/page_success") do
        result = amazon_shop.page(shop_url)

        assert result.key?(:lists)
        assert_kind_of Array, result[:lists]

        if result[:lists].any?
          list = result[:lists].first

          assert list.key?(:title)
          assert list.key?(:item_count)
          assert list.key?(:image)
          assert list.key?(:url)
        end
      end
    end

    it "returns trending picks array with expected fields" do
      VCR.use_cassette("amazon_shop/page_success") do
        result = amazon_shop.page(shop_url)

        assert result.key?(:trending_picks)
        assert_kind_of Array, result[:trending_picks]

        if result[:trending_picks].any?
          pick = result[:trending_picks].first

          assert pick.key?(:url)
          assert pick.key?(:image)
          assert pick.key?(:price)
          assert pick.key?(:discount)
        end
      end
    end

    it "returns curations array with expected fields" do
      VCR.use_cassette("amazon_shop/page_success") do
        result = amazon_shop.page(shop_url)

        assert result.key?(:curations)
        assert_kind_of Array, result[:curations]

        if result[:curations].any?
          curation = result[:curations].first

          assert curation.key?(:title)
          assert curation.key?(:post_count)
          assert curation.key?(:image)
          assert curation.key?(:url)
        end
      end
    end

    it "returns page token for pagination" do
      VCR.use_cassette("amazon_shop/page_success") do
        result = amazon_shop.page(shop_url)

        assert result.key?(:page_token)
      end
    end

    describe "argument validation" do
      it "raises ArgumentError when url is nil" do
        error = assert_raises(ArgumentError) do
          amazon_shop.page(nil)
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is empty" do
        error = assert_raises(ArgumentError) do
          amazon_shop.page("")
        end
        assert_match(/url is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises PaymentRequiredError for invalid API key" do
        VCR.use_cassette("amazon_shop/page_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::PaymentRequiredError) do
            invalid_client.amazon_shop.page(shop_url)
          end

          assert_match(/credits/i, error.message)
        end
      end
    end
  end
end
