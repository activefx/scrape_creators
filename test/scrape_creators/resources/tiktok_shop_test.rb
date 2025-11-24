# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::TiktokShop do
  let(:client) { ScrapeCreators::Client.new(api_key: "test_api_key") }
  let(:tiktok_shop) { client.tiktok_shop }

  describe "#search" do
    it "searches for shop products successfully" do
      VCR.use_cassette("tiktok_shop/search_success") do
        results = tiktok_shop.search("shoes")

        assert_kind_of Hash, results
        assert results.key?(:success)
        assert results.key?(:query)
        assert results.key?(:total_products)
        assert results.key?(:products)
        assert_kind_of Array, results[:products]

        unless results[:products].empty?
          first_product = results[:products].first

          assert first_product.key?(:product_id)
          assert first_product.key?(:title)
          assert first_product.key?(:image)
          assert first_product.key?(:product_price_info)
          assert first_product.key?(:seller_info)
        end
      end
    end

    it "searches for shop products with amount parameter" do
      VCR.use_cassette("tiktok_shop/search_with_amount") do
        results = tiktok_shop.search("electronics", amount: 50)

        assert_kind_of Hash, results
        assert results.key?(:products)
      end
    end

    it "returns product price information" do
      VCR.use_cassette("tiktok_shop/search_with_price_info") do
        results = tiktok_shop.search("shoes")

        assert_kind_of Hash, results
        assert results.key?(:products)

        unless results[:products].empty?
          first_product = results[:products].first
          price_info = first_product[:product_price_info]

          assert price_info.key?(:currency_symbol)
          assert price_info.key?(:sale_price_decimal) || price_info.key?(:sale_price_format)
        end
      end
    end

    it "returns seller information" do
      VCR.use_cassette("tiktok_shop/search_with_seller_info") do
        results = tiktok_shop.search("shoes")

        assert_kind_of Hash, results
        assert results.key?(:products)

        unless results[:products].empty?
          first_product = results[:products].first
          seller_info = first_product[:seller_info]

          assert seller_info.key?(:seller_id)
          assert seller_info.key?(:shop_name)
        end
      end
    end

    it "returns product ratings and sold info" do
      VCR.use_cassette("tiktok_shop/search_with_ratings") do
        results = tiktok_shop.search("shoes")

        assert_kind_of Hash, results
        assert results.key?(:products)

        unless results[:products].empty?
          first_product = results[:products].first

          assert first_product[:rate_info].key?(:score) if first_product.key?(:rate_info)

          assert first_product[:sold_info].key?(:sold_count) if first_product.key?(:sold_info)
        end
      end
    end

    it "raises ArgumentError when query is nil" do
      error = assert_raises(ArgumentError) do
        tiktok_shop.search(nil)
      end
      assert_match(/query is required/, error.message)
    end

    it "raises ArgumentError when query is empty" do
      error = assert_raises(ArgumentError) do
        tiktok_shop.search("")
      end
      assert_match(/query is required/, error.message)
    end
  end

  describe "#product" do
    it "fetches shop product details successfully" do
      VCR.use_cassette("tiktok_shop/product_success") do
        product = tiktok_shop.product("https://www.tiktok.com/view/product/1730383241618035288")

        assert_kind_of Hash, product
        assert product.key?(:success)
        assert product.key?(:product_info)
        assert product.key?(:shop_info)
        assert product.key?(:categories)

        # Verify product_info structure
        product_info = product[:product_info]

        assert product_info.key?(:product_id)
        assert product_info.key?(:product_base)
        assert product_info.key?(:seller)
      end
    end

    it "fetches shop product with related videos" do
      VCR.use_cassette("tiktok_shop/product_with_related_videos") do
        product = tiktok_shop.product(
          "https://www.tiktok.com/view/product/1730383241618035288",
          get_related_videos: true
        )

        assert_kind_of Hash, product
        assert product.key?(:product_info)
        assert product.key?(:related_videos)
        assert_kind_of Array, product[:related_videos]
      end
    end

    it "fetches shop product with region parameter" do
      VCR.use_cassette("tiktok_shop/product_with_region") do
        product = tiktok_shop.product(
          "https://www.tiktok.com/view/product/1730383241618035288",
          region: "US"
        )

        assert_kind_of Hash, product
        assert product.key?(:product_info)
      end
    end

    it "returns product base information" do
      VCR.use_cassette("tiktok_shop/product_with_base_info") do
        product = tiktok_shop.product("https://www.tiktok.com/view/product/1730383241618035288")

        assert_kind_of Hash, product
        assert product.key?(:product_info)

        product_base = product.dig(:product_info, :product_base)
        next unless product_base

        assert product_base.key?(:title)
        assert product_base.key?(:images) || product_base.key?(:price)
      end
    end

    it "returns shop information" do
      VCR.use_cassette("tiktok_shop/product_with_shop_info") do
        product = tiktok_shop.product("https://www.tiktok.com/view/product/1730383241618035288")

        assert_kind_of Hash, product
        assert product.key?(:shop_info)

        shop_info = product[:shop_info]

        assert shop_info.key?(:seller_id)
        assert shop_info.key?(:shop_name) || shop_info.key?(:sold_count)
      end
    end

    it "returns SKU information with stock levels" do
      VCR.use_cassette("tiktok_shop/product_with_skus") do
        product = tiktok_shop.product("https://www.tiktok.com/view/product/1730383241618035288")

        assert_kind_of Hash, product
        assert product.key?(:product_info)

        skus = product.dig(:product_info, :skus)
        next unless skus && !skus.empty?

        first_sku = skus.first

        assert first_sku.key?(:sku_id)
        assert first_sku.key?(:stock) || first_sku.key?(:price)
      end
    end

    it "returns category information" do
      VCR.use_cassette("tiktok_shop/product_with_categories") do
        product = tiktok_shop.product("https://www.tiktok.com/view/product/1730383241618035288")

        assert_kind_of Hash, product
        assert product.key?(:categories)
        assert_kind_of Array, product[:categories]

        unless product[:categories].empty?
          first_category = product[:categories].first

          assert first_category.key?(:category_id) || first_category.key?(:category_name)
        end
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        tiktok_shop.product(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        tiktok_shop.product("")
      end
      assert_match(/url is required/, error.message)
    end
  end

  describe "#products" do
    it "fetches shop products successfully" do
      VCR.use_cassette("tiktok_shop/products_success") do
        results = tiktok_shop.products("https://www.tiktok.com/shop/store/goli-nutrition/7495794203056835079")

        assert_kind_of Hash, results
        assert results.key?(:success)
        assert results.key?(:shop_info)
        assert results.key?(:products)
        assert_kind_of Array, results[:products]

        unless results[:products].empty?
          first_product = results[:products].first

          assert first_product.key?(:product_id)
          assert first_product.key?(:title)
          assert first_product.key?(:image)
          assert first_product.key?(:product_price_info)
          assert first_product.key?(:seller_info)
        end
      end
    end

    it "fetches shop products with amount parameter" do
      VCR.use_cassette("tiktok_shop/products_with_amount") do
        results = tiktok_shop.products(
          "https://www.tiktok.com/shop/store/goli-nutrition/7495794203056835079",
          amount: 10
        )

        assert_kind_of Hash, results
        assert results.key?(:products)
      end
    end

    it "returns shop info" do
      VCR.use_cassette("tiktok_shop/products_with_shop_info") do
        results = tiktok_shop.products("https://www.tiktok.com/shop/store/goli-nutrition/7495794203056835079")

        assert_kind_of Hash, results
        assert results.key?(:shop_info)

        shop_info = results[:shop_info]

        assert shop_info.key?(:seller_id)
        assert shop_info.key?(:shop_name)
        assert shop_info.key?(:sold_count) || shop_info.key?(:format_sold_count)
      end
    end

    it "returns product price information" do
      VCR.use_cassette("tiktok_shop/products_with_price_info") do
        results = tiktok_shop.products("https://www.tiktok.com/shop/store/goli-nutrition/7495794203056835079")

        assert_kind_of Hash, results
        assert results.key?(:products)

        unless results[:products].empty?
          first_product = results[:products].first
          price_info = first_product[:product_price_info]

          assert price_info.key?(:currency_symbol)
          assert price_info.key?(:sale_price_decimal) || price_info.key?(:sale_price_format)
        end
      end
    end

    it "returns product ratings and sold info" do
      VCR.use_cassette("tiktok_shop/products_with_ratings") do
        results = tiktok_shop.products("https://www.tiktok.com/shop/store/goli-nutrition/7495794203056835079")

        assert_kind_of Hash, results
        assert results.key?(:products)

        unless results[:products].empty?
          first_product = results[:products].first

          assert first_product[:rate_info].key?(:score) if first_product.key?(:rate_info)

          assert first_product[:sold_info].key?(:sold_count) if first_product.key?(:sold_info)
        end
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        tiktok_shop.products(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        tiktok_shop.products("")
      end
      assert_match(/url is required/, error.message)
    end
  end
end
