# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Reddit API resource
    #
    # Provides methods to interact with Reddit endpoints for scraping subreddit posts,
    # comments, and search results.
    #
    # @see https://docs.scrapecreators.com/v1/reddit Reddit API Documentation
    class Reddit < Resource
      # Valid timeframe options for subreddit posts
      VALID_TIMEFRAMES = %w[all day week month year].freeze

      # Valid sort options for subreddit posts
      VALID_SORTS = %w[best hot new top rising].freeze

      # Valid sort options for search
      VALID_SEARCH_SORTS = %w[relevance new top comment_count].freeze

      # Valid industry options for ad search
      VALID_AD_INDUSTRIES = %w[
        RETAIL_AND_ECOMMERCE TECH_B2B TECH_B2C EDUCATION ENTERTAINMENT
        GAMING FINANCIAL_SERVICES HEALTH_AND_BEAUTY CONSUMER_PACKAGED_GOODS
        EMPLOYMENT AUTO TRAVEL REAL_ESTATE GAMBLING_AND_FANTASY_SPORTS
        POLITICS_AND_GOVERNMENT OTHER
      ].freeze

      # Valid budget options for ad search
      VALID_AD_BUDGETS = %w[LOW MEDIUM HIGH].freeze

      # Valid format options for ad search
      VALID_AD_FORMATS = %w[IMAGE VIDEO CAROUSEL FREE_FORM].freeze

      # Valid placement options for ad search
      VALID_AD_PLACEMENTS = %w[FEED COMMENTS_PAGE].freeze

      # Valid objective options for ad search
      VALID_AD_OBJECTIVES = %w[
        IMPRESSIONS CLICKS CONVERSIONS VIDEO_VIEWABLE_IMPRESSIONS APP_INSTALLS
      ].freeze

      # Get recent posts from a subreddit with engagement metrics
      #
      # Retrieves posts from a subreddit including engagement metrics like upvotes,
      # comments, and awards. Supports pagination and various sorting options.
      #
      # @param subreddit [String] Subreddit name (without the "r/" prefix)
      # @param timeframe [String, nil] Timeframe to get posts from (all, day, week, month, year)
      # @param sort [String, nil] Sort order (best, hot, new, top, rising)
      # @param after [String, nil] Pagination cursor from previous response to get more posts
      # @param trim [Boolean, nil] Whether to return a trimmed response (default: false)
      # @return [Hash] Subreddit posts data including posts array and pagination cursor
      # @raise [ArgumentError] If the subreddit parameter is nil or empty
      # @raise [ArgumentError] If timeframe is invalid
      # @raise [ArgumentError] If sort is invalid
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [NotFoundError] If the subreddit is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get hot posts from a subreddit
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   posts = client.reddit.subreddit_posts("AskReddit")
      #   posts[:posts].each { |post| puts post[:title] }
      #
      # @example Get top posts from the past week
      #   posts = client.reddit.subreddit_posts("technology", timeframe: "week", sort: "top")
      #
      # @example Paginate through posts
      #   first_page = client.reddit.subreddit_posts("gaming")
      #   next_page = client.reddit.subreddit_posts("gaming", after: first_page[:after])
      #
      # @example Get trimmed response
      #   posts = client.reddit.subreddit_posts("news", trim: true)
      #
      # @example Response structure
      #   {
      #     posts: [
      #       {
      #         id: "1ldr6b9",
      #         name: "t3_1ldr6b9",
      #         title: "What are your thoughts on...",
      #         selftext: "",
      #         author: "username",
      #         author_fullname: "t2_aelahp9al",
      #         subreddit: "AskReddit",
      #         subreddit_name_prefixed: "r/AskReddit",
      #         subreddit_id: "t5_2qh1i",
      #         subreddit_subscribers: 56098571,
      #         score: 12606,
      #         ups: 12606,
      #         downs: 0,
      #         upvote_ratio: 0.93,
      #         num_comments: 1921,
      #         created: 1750176516,
      #         created_utc: 1750176516,
      #         permalink: "/r/AskReddit/comments/1ldr6b9/...",
      #         url: "https://www.reddit.com/r/AskReddit/comments/1ldr6b9/...",
      #         is_self: true,
      #         is_video: false,
      #         over_18: false,
      #         spoiler: false,
      #         locked: false,
      #         stickied: false,
      #         archived: false,
      #         is_original_content: false,
      #         total_awards_received: 0
      #       }
      #     ],
      #     after: "t3_1ld8q7h"
      #   }
      def subreddit_posts(subreddit, timeframe: nil, sort: nil, after: nil, trim: nil)
        raise ArgumentError, "subreddit is required" if subreddit.nil? || subreddit.to_s.empty?

        if timeframe && !VALID_TIMEFRAMES.include?(timeframe.to_s)
          raise ArgumentError, "timeframe must be one of: #{VALID_TIMEFRAMES.join(", ")}"
        end

        if sort && !VALID_SORTS.include?(sort.to_s)
          raise ArgumentError, "sort must be one of: #{VALID_SORTS.join(", ")}"
        end

        params = { subreddit: subreddit }
        params[:timeframe] = timeframe unless timeframe.nil?
        params[:sort] = sort unless sort.nil?
        params[:after] = after unless after.nil?
        params[:trim] = trim unless trim.nil?

        get("/v1/reddit/subreddit", params)
      end

      # Get comments and post information from a Reddit post
      #
      # Retrieves all comments and the original post data from a Reddit post URL.
      # Comments are returned in a nested structure with replies. Supports pagination
      # for fetching additional comments and replies using cursors.
      #
      # @param url [String] The full Reddit post URL
      # @param cursor [String, nil] Cursor to get more comments or replies from a previous response
      # @param trim [Boolean, nil] Whether to return a trimmed response (default: false)
      # @return [Hash] Post data with comments including nested replies and pagination cursors
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [NotFoundError] If the post is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get comments from a Reddit post
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.reddit.post_comments("https://www.reddit.com/r/AskReddit/comments/abc123/...")
      #   puts result[:post][:title]
      #   result[:comments].each { |comment| puts comment[:body] }
      #
      # @example Paginate through more comments
      #   result = client.reddit.post_comments("https://www.reddit.com/r/AskReddit/comments/abc123/...")
      #   if result[:more][:has_more]
      #     more_comments = client.reddit.post_comments(
      #       "https://www.reddit.com/r/AskReddit/comments/abc123/...",
      #       cursor: result[:more][:cursor]
      #     )
      #   end
      #
      # @example Get trimmed response
      #   result = client.reddit.post_comments(
      #     "https://www.reddit.com/r/AskReddit/comments/abc123/...",
      #     trim: true
      #   )
      #
      # @example Response structure
      #   {
      #     post: {
      #       id: "ablzuq",
      #       title: "People who haven't pooped in 2019 yet...",
      #       author: "ShoddySubstance",
      #       subreddit: "AskReddit",
      #       subreddit_name_prefixed: "r/AskReddit",
      #       score: 221995,
      #       num_comments: 7925,
      #       created_utc: 1546376787,
      #       permalink: "/r/AskReddit/comments/ablzuq/...",
      #       url: "https://www.reddit.com/r/AskReddit/comments/ablzuq/..."
      #     },
      #     comments: [
      #       {
      #         id: "ed1czme",
      #         author: "sweatybeard",
      #         body: "But when I finally do...",
      #         score: 12211,
      #         created_utc: 1546378524,
      #         depth: 0,
      #         replies: {
      #           items: [...],
      #           more: { has_more: true, cursor: "..." }
      #         }
      #       }
      #     ],
      #     more: {
      #       has_more: true,
      #       cursor: "ed1jhoi,ed1f3kw,..."
      #     }
      #   }
      def post_comments(url, cursor: nil, trim: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:cursor] = cursor unless cursor.nil?
        params[:trim] = trim unless trim.nil?

        get("/v1/reddit/post/comments", params)
      end

      # Get a simplified list of comments from a Reddit post
      #
      # Convenience API to get a specific number of comments from a Reddit post.
      # Returns a flattened array of comments without nested replies structure,
      # making it easier to work with for simple use cases.
      #
      # @param url [String] The full Reddit post URL
      # @param amount [Integer, nil] Number of comments to return
      # @param trim [Boolean, nil] Whether to return a trimmed response (default: false)
      # @return [Array<Hash>] Array of comment objects
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [NotFoundError] If the post is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get 10 comments from a Reddit post
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   comments = client.reddit.simple_comments(
      #     "https://www.reddit.com/r/AskReddit/comments/abc123/...",
      #     amount: 10
      #   )
      #   comments.each { |comment| puts comment[:body] }
      #
      # @example Get trimmed comments
      #   comments = client.reddit.simple_comments(
      #     "https://www.reddit.com/r/AskReddit/comments/abc123/...",
      #     amount: 5,
      #     trim: true
      #   )
      #
      # @example Response structure
      #   [
      #     {
      #       subreddit_id: "t5_2qh1i",
      #       author: "sweatybeard",
      #       body: "But when I finally do...",
      #       body_html: "<div class=\"md\">...</div>",
      #       score: 12207,
      #       ups: 12207,
      #       downs: 0,
      #       created_utc: 1546378524,
      #       id: "ed1czme",
      #       name: "t1_ed1czme",
      #       parent_id: "t3_ablzuq",
      #       link_id: "t3_ablzuq",
      #       subreddit: "AskReddit",
      #       subreddit_name_prefixed: "r/AskReddit",
      #       permalink: "/r/AskReddit/comments/ablzuq/.../ed1czme/",
      #       depth: 0,
      #       gilded: 2,
      #       archived: true,
      #       controversiality: 0,
      #       is_submitter: false
      #     }
      #   ]
      def simple_comments(url, amount: nil, trim: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:amount] = amount unless amount.nil?
        params[:trim] = trim unless trim.nil?

        get("/v1/reddit/post/comments/simple", params)
      end

      # Search Reddit for posts
      #
      # Searches Reddit for posts matching the given query. Supports various
      # sorting options and timeframe filtering.
      #
      # @param query [String] The search query
      # @param sort [String, nil] Sort order (relevance, new, top, comment_count)
      # @param timeframe [String, nil] Timeframe to filter results (all, day, week, month, year)
      # @param after [String, nil] Pagination cursor from previous response to get more posts
      # @param trim [Boolean, nil] Whether to return a trimmed response (default: false)
      # @return [Hash] Search results including posts array and pagination cursor
      # @raise [ArgumentError] If the query parameter is nil or empty
      # @raise [ArgumentError] If sort is invalid
      # @raise [ArgumentError] If timeframe is invalid
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Search for posts about web scraping
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.reddit.search("web scraping")
      #   results[:posts].each { |post| puts post[:title] }
      #
      # @example Search with sorting and timeframe
      #   results = client.reddit.search("python", sort: "top", timeframe: "week")
      #
      # @example Paginate through search results
      #   first_page = client.reddit.search("javascript")
      #   next_page = client.reddit.search("javascript", after: first_page[:after])
      #
      # @example Get trimmed response
      #   results = client.reddit.search("ruby", trim: true)
      #
      # @example Response structure
      #   {
      #     success: true,
      #     posts: [
      #       {
      #         id: "1flgwup",
      #         name: "t3_1flgwup",
      #         title: "After 2 months learning scraping...",
      #         selftext: "1. Don't try putting scraping tools in Lambda.",
      #         author: "Sea_Cardiologist_212",
      #         subreddit: "webscraping",
      #         subreddit_name_prefixed: "r/webscraping",
      #         score: 361,
      #         ups: 361,
      #         downs: 0,
      #         upvote_ratio: 0.99,
      #         num_comments: 102,
      #         created: 1726851591,
      #         created_utc: 1726851591,
      #         created_at_iso: "2024-09-20T16:59:51.000Z",
      #         permalink: "/r/webscraping/comments/1flgwup/...",
      #         url: "https://www.reddit.com/r/webscraping/comments/1flgwup/...",
      #         is_self: true,
      #         is_video: false,
      #         over_18: false,
      #         spoiler: false,
      #         locked: false,
      #         stickied: false,
      #         archived: true
      #       }
      #     ],
      #     after: "t3_1ihh437"
      #   }
      def search(query, sort: nil, timeframe: nil, after: nil, trim: nil)
        raise ArgumentError, "query is required" if query.nil? || query.to_s.empty?

        if sort && !VALID_SEARCH_SORTS.include?(sort.to_s)
          raise ArgumentError, "sort must be one of: #{VALID_SEARCH_SORTS.join(", ")}"
        end

        if timeframe && !VALID_TIMEFRAMES.include?(timeframe.to_s)
          raise ArgumentError, "timeframe must be one of: #{VALID_TIMEFRAMES.join(", ")}"
        end

        params = { query: query }
        params[:sort] = sort unless sort.nil?
        params[:timeframe] = timeframe unless timeframe.nil?
        params[:after] = after unless after.nil?
        params[:trim] = trim unless trim.nil?

        get("/v1/reddit/search", params)
      end

      # Search the Reddit Ad Library
      #
      # Searches the Reddit Ad Library for ads matching the given query.
      # Supports filtering by industry, budget, format, placement, and objective.
      # Returns a maximum of 30 ads per request.
      #
      # @param query [String] The search query (required)
      # @param industries [Array<String>, nil] Industries to filter by
      #   (RETAIL_AND_ECOMMERCE, TECH_B2B, TECH_B2C, EDUCATION, ENTERTAINMENT,
      #   GAMING, FINANCIAL_SERVICES, HEALTH_AND_BEAUTY, CONSUMER_PACKAGED_GOODS,
      #   EMPLOYMENT, AUTO, TRAVEL, REAL_ESTATE, GAMBLING_AND_FANTASY_SPORTS,
      #   POLITICS_AND_GOVERNMENT, OTHER)
      # @param budgets [Array<String>, nil] Budgets to filter by (LOW, MEDIUM, HIGH)
      # @param formats [Array<String>, nil] Formats to filter by (IMAGE, VIDEO, CAROUSEL, FREE_FORM)
      # @param placements [Array<String>, nil] Placements to filter by (FEED, COMMENTS_PAGE)
      # @param objectives [Array<String>, nil] Objectives to filter by
      #   (IMPRESSIONS, CLICKS, CONVERSIONS, VIDEO_VIEWABLE_IMPRESSIONS, APP_INSTALLS)
      # @return [Hash] Search results including success status and ads array
      # @raise [ArgumentError] If the query parameter is nil or empty
      # @raise [ArgumentError] If any filter contains invalid values
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Search for ads by query
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   results = client.reddit.ads_search("technology")
      #   results[:ads].each { |ad| puts ad[:creative][:headline] }
      #
      # @example Search with industry filter
      #   results = client.reddit.ads_search("software", industries: ["TECH_B2B", "TECH_B2C"])
      #
      # @example Search with multiple filters
      #   results = client.reddit.ads_search(
      #     "gaming",
      #     industries: ["GAMING", "ENTERTAINMENT"],
      #     budgets: ["HIGH"],
      #     formats: ["VIDEO"],
      #     placements: ["FEED"],
      #     objectives: ["CONVERSIONS"]
      #   )
      #
      # @example Response structure
      #   {
      #     success: true,
      #     ads: [
      #       {
      #         id: "79e005f1e09ec72245e904d87d2a0869",
      #         budget_category: "HIGH",
      #         industry: "OTHER",
      #         placements: ["FEED", "COMMENTS_PAGE"],
      #         objective: "CONVERSIONS",
      #         creative: {
      #           id: "t3_1cdt7o6",
      #           type: "TEXT",
      #           content: [
      #             {
      #               destination_url: nil,
      #               display_url: "self.thepennyhoarder",
      #               call_to_action: nil,
      #               media_url: nil
      #             }
      #           ],
      #           headline: "What is a rich person's money tip...",
      #           body: "Life would be a whole lot easier...",
      #           thumbnail_url: "https://b.thumbs.redditmedia.com/...",
      #           allow_comments: false,
      #           created_at: "2024-04-26T18:47:57+00:00",
      #           profile_id: "t2_3usby",
      #           post_url: "https://www.reddit.com/r/u_thepennyhoarder/..."
      #         },
      #         profile_info: {
      #           name: "u_thepennyhoarder",
      #           snoovatar_icon_url: "https://www.redditstatic.com/avatars/..."
      #         }
      #       }
      #     ]
      #   }
      def ads_search(query, industries: nil, budgets: nil, formats: nil, placements: nil, objectives: nil)
        raise ArgumentError, "query is required" if query.nil? || query.to_s.empty?

        validate_ad_filters(industries, budgets, formats, placements, objectives)

        params = { query: query }
        params[:industries] = industries.join(",") if industries&.any?
        params[:budgets] = budgets.join(",") if budgets&.any?
        params[:formats] = formats.join(",") if formats&.any?
        params[:placements] = placements.join(",") if placements&.any?
        params[:objectives] = objectives.join(",") if objectives&.any?

        get("/v1/reddit/ads/search", params)
      end

      private

      # Validates ad search filter parameters
      #
      # @param industries [Array<String>, nil] Industries to validate
      # @param budgets [Array<String>, nil] Budgets to validate
      # @param formats [Array<String>, nil] Formats to validate
      # @param placements [Array<String>, nil] Placements to validate
      # @param objectives [Array<String>, nil] Objectives to validate
      # @raise [ArgumentError] If any filter contains invalid values
      def validate_ad_filters(industries, budgets, formats, placements, objectives)
        if industries&.any? { |i| !VALID_AD_INDUSTRIES.include?(i.to_s) }
          raise ArgumentError, "industries must be one of: #{VALID_AD_INDUSTRIES.join(", ")}"
        end

        if budgets&.any? { |b| !VALID_AD_BUDGETS.include?(b.to_s) }
          raise ArgumentError, "budgets must be one of: #{VALID_AD_BUDGETS.join(", ")}"
        end

        if formats&.any? { |f| !VALID_AD_FORMATS.include?(f.to_s) }
          raise ArgumentError, "formats must be one of: #{VALID_AD_FORMATS.join(", ")}"
        end

        if placements&.any? { |p| !VALID_AD_PLACEMENTS.include?(p.to_s) }
          raise ArgumentError, "placements must be one of: #{VALID_AD_PLACEMENTS.join(", ")}"
        end

        return unless objectives&.any? { |o| !VALID_AD_OBJECTIVES.include?(o.to_s) }

        raise ArgumentError, "objectives must be one of: #{VALID_AD_OBJECTIVES.join(", ")}"
      end
    end
  end
end
