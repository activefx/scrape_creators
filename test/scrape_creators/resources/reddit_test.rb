# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Reddit do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:reddit) { client.reddit }

  describe "#subreddit_posts" do
    it "fetches posts from a subreddit successfully" do
      VCR.use_cassette("reddit/subreddit_posts_success") do
        result = reddit.subreddit_posts("AskReddit")

        assert_kind_of Hash, result
        assert result.key?(:posts)
        assert_kind_of Array, result[:posts]
        refute_empty result[:posts]

        # Verify first post structure
        post = result[:posts].first

        assert post.key?(:id)
        assert post.key?(:title)
        assert post.key?(:author)
        assert post.key?(:subreddit)
        assert post.key?(:score)
        assert post.key?(:num_comments)
        assert post.key?(:created_utc)
        assert post.key?(:permalink)
        assert post.key?(:url)
      end
    end

    it "includes pagination cursor in response" do
      VCR.use_cassette("reddit/subreddit_posts_success") do
        result = reddit.subreddit_posts("AskReddit")

        assert result.key?(:after)
      end
    end

    it "fetches posts with timeframe parameter" do
      # API requires sort: "top" when using timeframe
      VCR.use_cassette("reddit/subreddit_posts_with_timeframe") do
        result = reddit.subreddit_posts("technology", timeframe: "week", sort: "top")

        assert_kind_of Hash, result
        assert result.key?(:posts)
        assert_kind_of Array, result[:posts]
      end
    end

    it "fetches posts with sort parameter" do
      VCR.use_cassette("reddit/subreddit_posts_with_sort") do
        result = reddit.subreddit_posts("gaming", sort: "top")

        assert_kind_of Hash, result
        assert result.key?(:posts)
        assert_kind_of Array, result[:posts]
      end
    end

    it "fetches posts with trim parameter" do
      VCR.use_cassette("reddit/subreddit_posts_trimmed") do
        result = reddit.subreddit_posts("news", trim: true)

        assert_kind_of Hash, result
        assert result.key?(:posts)
      end
    end

    it "fetches posts with all parameters" do
      VCR.use_cassette("reddit/subreddit_posts_all_params") do
        result = reddit.subreddit_posts(
          "programming",
          timeframe: "month",
          sort: "top",
          trim: true
        )

        assert_kind_of Hash, result
        assert result.key?(:posts)
      end
    end

    describe "argument validation" do
      it "raises ArgumentError when subreddit is nil" do
        error = assert_raises(ArgumentError) do
          reddit.subreddit_posts(nil)
        end
        assert_match(/subreddit is required/, error.message)
      end

      it "raises ArgumentError when subreddit is empty" do
        error = assert_raises(ArgumentError) do
          reddit.subreddit_posts("")
        end
        assert_match(/subreddit is required/, error.message)
      end

      it "raises ArgumentError for invalid timeframe" do
        error = assert_raises(ArgumentError) do
          reddit.subreddit_posts("AskReddit", timeframe: "invalid")
        end
        assert_match(/timeframe must be one of/, error.message)
      end

      it "raises ArgumentError for invalid sort" do
        error = assert_raises(ArgumentError) do
          reddit.subreddit_posts("AskReddit", sort: "invalid")
        end
        assert_match(/sort must be one of/, error.message)
      end
    end

    describe "error handling" do
      it "raises NotFoundError for non-existent subreddit" do
        VCR.use_cassette("reddit/subreddit_posts_not_found") do
          assert_raises(ScrapeCreators::NotFoundError) do
            reddit.subreddit_posts("thissubredditdoesnotexist123456789xyz")
          end
        end
      end

      it "raises PaymentRequiredError for invalid API key" do
        # The API returns 402 Payment Required for invalid keys
        VCR.use_cassette("reddit/subreddit_posts_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::PaymentRequiredError) do
            invalid_client.reddit.subreddit_posts("AskReddit")
          end

          assert_match(/credits/i, error.message)
        end
      end
    end
  end

  describe "#post_comments" do
    let(:post_url) { "https://www.reddit.com/r/AskReddit/comments/ablzuq/people_who_havent_pooped_in_2019_yet_why_are_you/" }

    it "fetches comments from a post successfully" do
      VCR.use_cassette("reddit/post_comments_success") do
        result = reddit.post_comments(post_url)

        assert_kind_of Hash, result
        assert result.key?(:post)
        assert result.key?(:comments)
        assert result.key?(:more)

        # Verify post structure
        post = result[:post]

        assert post.key?(:id)
        assert post.key?(:title)
        assert post.key?(:author)
        assert post.key?(:subreddit)
        assert post.key?(:score)
        assert post.key?(:num_comments)
        assert post.key?(:created_utc)
        assert post.key?(:permalink)
        assert post.key?(:url)
      end
    end

    it "returns comments array with proper structure" do
      VCR.use_cassette("reddit/post_comments_success") do
        result = reddit.post_comments(post_url)

        assert_kind_of Array, result[:comments]
        refute_empty result[:comments]

        # Verify comment structure
        comment = result[:comments].first

        assert comment.key?(:id)
        assert comment.key?(:author)
        assert comment.key?(:body)
        assert comment.key?(:score)
        assert comment.key?(:created_utc)
        assert comment.key?(:depth)
      end
    end

    it "returns nested replies in comments" do
      VCR.use_cassette("reddit/post_comments_success") do
        result = reddit.post_comments(post_url)

        # Find a comment with replies
        comment_with_replies = result[:comments].find { |c| c[:replies] && c[:replies][:items]&.any? }

        if comment_with_replies
          assert comment_with_replies[:replies].key?(:items)
          assert comment_with_replies[:replies].key?(:more)
        end
      end
    end

    it "includes pagination cursor in response" do
      VCR.use_cassette("reddit/post_comments_success") do
        result = reddit.post_comments(post_url)

        assert result.key?(:more)
        assert result[:more].key?(:has_more)
      end
    end

    it "fetches comments with cursor parameter" do
      VCR.use_cassette("reddit/post_comments_with_cursor") do
        result = reddit.post_comments(post_url, cursor: "ed1jhoi")

        assert_kind_of Hash, result
        assert result.key?(:comments)
      end
    end

    it "fetches comments with trim parameter" do
      VCR.use_cassette("reddit/post_comments_trimmed") do
        result = reddit.post_comments(post_url, trim: true)

        assert_kind_of Hash, result
        assert result.key?(:post)
        assert result.key?(:comments)
      end
    end

    describe "argument validation" do
      it "raises ArgumentError when url is nil" do
        error = assert_raises(ArgumentError) do
          reddit.post_comments(nil)
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is empty" do
        error = assert_raises(ArgumentError) do
          reddit.post_comments("")
        end
        assert_match(/url is required/, error.message)
      end
    end

    describe "error handling" do
      it "returns empty comments for non-existent post" do
        # The API returns 200 with empty comments for non-existent posts
        VCR.use_cassette("reddit/post_comments_not_found") do
          result = reddit.post_comments("https://www.reddit.com/r/AskReddit/comments/nonexistent123/fake_post/")

          assert_kind_of Hash, result
          assert result.key?(:comments)
          assert_empty result[:comments]
        end
      end

      it "raises PaymentRequiredError for invalid API key" do
        VCR.use_cassette("reddit/post_comments_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::PaymentRequiredError) do
            invalid_client.reddit.post_comments(post_url)
          end

          assert_match(/credits/i, error.message)
        end
      end
    end
  end
end
