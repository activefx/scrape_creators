# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Twitter do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:twitter) { client.twitter }

  describe "#profile" do
    it "fetches a Twitter profile successfully" do
      VCR.use_cassette("twitter/profile_success") do
        profile = twitter.profile("Austen")

        assert_kind_of Hash, profile

        # Verify top-level structure
        assert_equal "User", profile[:__typename]
        assert profile.key?(:id)
        assert profile.key?(:rest_id)
        assert profile.key?(:is_blue_verified)
        assert profile.key?(:legacy)

        # Verify legacy data structure
        legacy = profile[:legacy]

        assert_equal "Austen", legacy[:screen_name]
        assert legacy.key?(:name)
        assert legacy.key?(:description)
        assert legacy.key?(:followers_count)
        assert legacy.key?(:friends_count)
        assert legacy.key?(:statuses_count)
        assert legacy.key?(:created_at)

        # Verify counts are present
        assert_predicate legacy[:followers_count], :positive?
        assert_predicate legacy[:statuses_count], :positive?
      end
    end

    it "returns verification info" do
      VCR.use_cassette("twitter/profile_success") do
        profile = twitter.profile("Austen")

        # Verify verification info exists
        assert profile.key?(:verification_info)
        assert profile.key?(:is_blue_verified)
      end
    end

    it "returns profile image and banner URLs" do
      VCR.use_cassette("twitter/profile_success") do
        profile = twitter.profile("Austen")

        legacy = profile[:legacy]

        assert legacy.key?(:profile_image_url_https)
        assert legacy.key?(:profile_banner_url)
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        twitter.profile(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        twitter.profile("")
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("twitter/profile_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          twitter.profile("thisuserdoesnotexist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("twitter/profile_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.twitter.profile("Austen")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#user_tweets" do
    it "fetches user tweets successfully" do
      VCR.use_cassette("twitter/user_tweets_success") do
        result = twitter.user_tweets("Austen")

        assert_kind_of Hash, result
        assert result.key?(:tweets)
        assert_kind_of Array, result[:tweets]
        refute_empty result[:tweets]

        # Verify tweet structure
        tweet = result[:tweets].first

        assert tweet.key?(:rest_id)
        assert tweet.key?(:legacy)

        # Verify legacy data structure
        legacy = tweet[:legacy]

        assert legacy.key?(:full_text)
        assert legacy.key?(:favorite_count)
        assert legacy.key?(:retweet_count)
        assert legacy.key?(:created_at)
      end
    end

    it "includes user information in tweets" do
      VCR.use_cassette("twitter/user_tweets_success") do
        result = twitter.user_tweets("Austen")

        tweet = result[:tweets].first

        assert tweet.key?(:core)
        assert tweet[:core].key?(:user_results)
        assert tweet[:core][:user_results].key?(:result)

        user = tweet[:core][:user_results][:result]

        assert user.key?(:legacy)
        assert user[:legacy].key?(:screen_name)
      end
    end

    it "includes engagement metrics" do
      VCR.use_cassette("twitter/user_tweets_success") do
        result = twitter.user_tweets("Austen")

        tweet = result[:tweets].first
        legacy = tweet[:legacy]

        assert legacy.key?(:favorite_count)
        assert legacy.key?(:retweet_count)
        assert legacy.key?(:reply_count)
        assert legacy.key?(:quote_count)
      end
    end

    it "supports trim parameter" do
      VCR.use_cassette("twitter/user_tweets_trimmed") do
        result = twitter.user_tweets("Austen", trim: true)

        assert_kind_of Hash, result
        assert result.key?(:tweets)
        assert_kind_of Array, result[:tweets]
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        twitter.user_tweets(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        twitter.user_tweets("")
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("twitter/user_tweets_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          twitter.user_tweets("thisuserdoesnotexist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("twitter/user_tweets_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.twitter.user_tweets("Austen")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#tweet" do
    let(:tweet_url) { "https://x.com/adrian_horning_/status/1628769691547074562" }

    it "fetches tweet details successfully" do
      VCR.use_cassette("twitter/tweet_success") do
        tweet = twitter.tweet(tweet_url)

        assert_kind_of Hash, tweet

        # Verify top-level structure
        assert_equal "Tweet", tweet[:__typename]
        assert tweet.key?(:rest_id)
        assert tweet.key?(:core)
        assert tweet.key?(:legacy)
        assert tweet.key?(:views)
      end
    end

    it "includes user information" do
      VCR.use_cassette("twitter/tweet_success") do
        tweet = twitter.tweet(tweet_url)

        assert tweet[:core].key?(:user_results)
        assert tweet[:core][:user_results].key?(:result)

        user = tweet[:core][:user_results][:result]

        assert_equal "User", user[:__typename]
        assert user.key?(:rest_id)
        assert user.key?(:legacy)
        assert user[:legacy].key?(:screen_name)
        assert user[:legacy].key?(:name)
      end
    end

    it "includes engagement metrics" do
      VCR.use_cassette("twitter/tweet_success") do
        tweet = twitter.tweet(tweet_url)

        legacy = tweet[:legacy]

        assert legacy.key?(:favorite_count)
        assert legacy.key?(:retweet_count)
        assert legacy.key?(:reply_count)
        assert legacy.key?(:quote_count)
        assert legacy.key?(:bookmark_count)
      end
    end

    it "includes view count" do
      VCR.use_cassette("twitter/tweet_success") do
        tweet = twitter.tweet(tweet_url)

        assert tweet[:views].key?(:count)
        assert tweet[:views].key?(:state)
      end
    end

    it "includes tweet content" do
      VCR.use_cassette("twitter/tweet_success") do
        tweet = twitter.tweet(tweet_url)

        legacy = tweet[:legacy]

        assert legacy.key?(:full_text)
        assert legacy.key?(:created_at)
        assert legacy.key?(:id_str)
      end
    end

    it "supports trim parameter" do
      VCR.use_cassette("twitter/tweet_trimmed") do
        tweet = twitter.tweet(tweet_url, trim: true)

        assert_kind_of Hash, tweet
        assert tweet.key?(:rest_id)
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        twitter.tweet(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        twitter.tweet("")
      end
      assert_match(/url is required/, error.message)
    end

    it "raises NotFoundError for non-existent tweet" do
      VCR.use_cassette("twitter/tweet_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          twitter.tweet("https://x.com/user/status/999999999999999999999")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("twitter/tweet_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.twitter.tweet(tweet_url)
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#transcript" do
    let(:video_tweet_url) { "https://x.com/zaborovic/status/1855587637938598309" }

    it "fetches video tweet transcript successfully" do
      VCR.use_cassette("twitter/transcript_success") do
        result = twitter.transcript(video_tweet_url)

        assert_kind_of Hash, result

        # Verify success status
        assert result[:success]

        # Verify transcript is present and non-empty
        assert result.key?(:transcript)
        assert_kind_of String, result[:transcript]
        refute_empty result[:transcript]
      end
    end

    it "returns transcript text content" do
      VCR.use_cassette("twitter/transcript_success") do
        result = twitter.transcript(video_tweet_url)

        # Verify transcript contains expected content
        assert_includes result[:transcript].downcase, "innovation"
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        twitter.transcript(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        twitter.transcript("")
      end
      assert_match(/url is required/, error.message)
    end

    it "raises NotFoundError for non-existent tweet" do
      VCR.use_cassette("twitter/transcript_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          twitter.transcript("https://x.com/user/status/999999999999999999999")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("twitter/transcript_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.twitter.transcript(video_tweet_url)
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end
end
