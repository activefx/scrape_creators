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
    end
  end
end
