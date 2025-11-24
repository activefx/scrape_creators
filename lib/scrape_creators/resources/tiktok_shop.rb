# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # TikTok Shop API resource
    #
    # Provides methods to interact with TikTok Shop endpoints for scraping product data,
    # searching for products, and retrieving shop information.
    #
    # @see https://docs.scrapecreators.com/v1/tiktok-shop TikTok Shop API Documentation
    class TiktokShop < Resource
      # Search TikTok Shop products
      #
      # Scrapes TikTok Shop products from a search query. This endpoint handles pagination
      # automatically and can return up to around 500 products per search.
      #
      # @note This endpoint costs more than 1 credit! Since pagination is handled automatically,
      #   it costs 1 credit per page (TikTok returns 30 products per page). This endpoint may
      #   take a while to respond.
      #
      # @param query [String] Search term for products
      # @param amount [Integer, nil] Number of products to scrape (limited by TikTok's restrictions)
      # @return [Hash] Search results with products array
      # @raise [ArgumentError] If the query parameter is nil or empty
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Search for products
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.tiktok_shop.search("shoes")
      #   puts results[:total_products]  # => 100
      #   puts results[:products].first[:title]  # => "Crocs Adult Classic Clogs"
      #
      # @example Search with specific amount
      #   results = client.tiktok_shop.search("electronics", amount: 50)
      #   puts results[:products].length
      #
      # @example Response structure
      #   {
      #     success: true,
      #     query: "shoes",
      #     total_products: 100,
      #     products: [
      #       {
      #         product_id: "1730213444857467838",
      #         title: "Crocs Adult Classic Clogs",
      #         image: {
      #           height: 1200,
      #           width: 1200,
      #           uri: "tos-useast5-i-omjb5zjo8w-tx/...",
      #           url_list: ["https://..."]
      #         },
      #         product_price_info: {
      #           currency_symbol: "$",
      #           sale_price_decimal: "49.99",
      #           sale_price_format: "49.99"
      #         },
      #         rate_info: {
      #           score: 4.8,
      #           review_count: "2493"
      #         },
      #         sold_info: {
      #           sold_count: 24737
      #         },
      #         seller_info: {
      #           seller_id: "7495832567110863806",
      #           shop_name: "Crocs",
      #           shop_logo: { ... }
      #         },
      #         seo_url: {
      #           canonical_url: "https://www.tiktok.com/shop/pdp/...",
      #           slug: "classic-clogs-by-crocs-..."
      #         }
      #       }
      #     ]
      #   }
      def search(query, amount: nil)
        raise ArgumentError, "query is required" if query.nil? || query.to_s.empty?

        params = { query: query }
        params[:amount] = amount if amount

        get("/v1/tiktok/shop/search", params)
      end

      # Get TikTok Shop product details
      #
      # Retrieves detailed information about a TikTok Shop product including stock levels,
      # related affiliate videos promoting the product, seller information, and more.
      #
      # @param url [String] The URL of the TikTok Shop product to get details for
      # @param get_related_videos [Boolean, nil] Whether to get related videos for the product.
      #   These are affiliate videos promoting the product. Note: This will take longer to process.
      # @param region [String, nil] Region the proxy will be set to so you can access products
      #   from that country. Use 2 letter country codes like US, GB, FR, etc.
      # @return [Hash] Product details including product_info, shop_info, categories, and optionally related_videos
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [NotFoundError] If the product is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get product details
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   product = client.tiktok_shop.product("https://www.tiktok.com/shop/product/123")
      #   puts product[:product_info][:product_base][:title]  # => "Product Name"
      #   puts product[:product_info][:skus].first[:stock]  # => 1824
      #
      # @example Get product with related affiliate videos
      #   product = client.tiktok_shop.product(
      #     "https://www.tiktok.com/shop/product/123",
      #     get_related_videos: true
      #   )
      #   puts product[:related_videos].first[:title]
      #
      # @example Get product from specific region
      #   product = client.tiktok_shop.product(
      #     "https://www.tiktok.com/shop/product/123",
      #     region: "US"
      #   )
      #
      # @example Response structure
      #   {
      #     success: true,
      #     categories: [
      #       {
      #         category_id: "601450",
      #         category_name: "Beauty & Personal Care",
      #         level: 1,
      #         is_leaf: false
      #       }
      #     ],
      #     sale_region: "US",
      #     product_info: {
      #       product_id: "1730383241618035288",
      #       status: 1,
      #       seller: {
      #         seller_id: "7496021452055022168",
      #         name: "Manspot",
      #         avatar: { ... },
      #         product_count: 14,
      #         seller_location: "United States of America"
      #       },
      #       product_base: {
      #         title: "Product Title",
      #         images: [...],
      #         sold_count: 7160,
      #         price: {
      #           original_price: "$39.99",
      #           real_price: "$21.99",
      #           discount: "-47%",
      #           currency: "USD"
      #         }
      #       },
      #       sale_props: [...],
      #       skus: [
      #         {
      #           sku_id: "1730384306561520216",
      #           stock: 1824,
      #           purchase_limit: 20,
      #           price: { ... }
      #         }
      #       ],
      #       product_detail_review: {
      #         product_rating: 4.3,
      #         review_count: 595,
      #         review_items: [...]
      #       }
      #     },
      #     shop_info: {
      #       seller_id: "7496021452055022168",
      #       shop_name: "Manspot",
      #       sold_count: 50887,
      #       review_count: 4215,
      #       shop_rating: "4.4",
      #       shop_link: "https://www.tiktok.com/shop/store/manspot/..."
      #     },
      #     shop_performance: [
      #       { score_percentile: 98, type: 1 },
      #       { score_percentile: 97, type: 2 }
      #     ],
      #     related_videos: [  # Only present if get_related_videos is true
      #       {
      #         item_id: "7527142083258305822",
      #         title: "Video title",
      #         play_count: 324944,
      #         like_count: 1812,
      #         author_name: "Author Name",
      #         url: "https://www.tiktok.com/@user/video/123"
      #       }
      #     ]
      #   }
      def product(url, get_related_videos: nil, region: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:get_related_videos] = get_related_videos unless get_related_videos.nil?
        params[:region] = region if region

        get("/v1/tiktok/product", params)
      end

      # Get products from a TikTok Shop
      #
      # Retrieves all products from a TikTok Shop by its URL. This endpoint handles
      # pagination automatically and can take a while to respond.
      #
      # @note This endpoint costs more than 1 credit! Since pagination is handled
      #   automatically, it costs 1 credit per page (TikTok returns 30 products per page).
      #   This endpoint may take a while and is new, so please be patient.
      #
      # @param url [String] The URL of the TikTok Shop
      # @param amount [Integer, nil] The amount of products to get
      # @return [Hash] Shop info and products data
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get products from a shop
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.tiktok_shop.products("https://www.tiktok.com/shop/store/goli-nutrition/7495794203056835079")
      #   puts results[:shop_info][:shop_name]  # => "Goli Nutrition"
      #   puts results[:products].first[:title]  # => "Goli Ashwagandha..."
      #
      # @example Get specific amount of products
      #   results = client.tiktok_shop.products(
      #     "https://www.tiktok.com/shop/store/goli-nutrition/7495794203056835079",
      #     amount: 50
      #   )
      #
      # @example Response structure
      #   {
      #     success: true,
      #     shop_info: {
      #       seller_id: "7495794203056835079",
      #       sold_count: 3767605,
      #       on_sell_product_count: 36,
      #       review_count: 284185,
      #       shop_name: "Goli Nutrition",
      #       shop_logo: { ... },
      #       shop_rating: "4.6",
      #       shop_link: "https://www.tiktok.com/shop/store/goli-nutrition/...",
      #       format_sold_count: "3.7M",
      #       region: "US",
      #       followers_count: "237879",
      #       store_sub_score: [...]
      #     },
      #     products: [
      #       {
      #         product_id: "1729527313880355335",
      #         title: "Goli Ashwagandha & Vitamin D Gummy...",
      #         image: { ... },
      #         product_price_info: {
      #           currency_symbol: "$",
      #           sale_price_decimal: "14.96",
      #           origin_price_decimal: "24.99",
      #           discount_format: "40%"
      #         },
      #         rate_info: {
      #           score: 4.5,
      #           review_count: "91316"
      #         },
      #         sold_info: {
      #           sold_count: 1235089
      #         },
      #         seller_info: { ... },
      #         seo_url: {
      #           canonical_url: "https://www.tiktok.com/shop/pdp/...",
      #           slug: "ashwagandha-gummies-by-goli-..."
      #         }
      #       }
      #     ]
      #   }
      def products(url, amount: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:amount] = amount if amount

        get("/v1/tiktok/shop/products", params)
      end
    end
  end
end
