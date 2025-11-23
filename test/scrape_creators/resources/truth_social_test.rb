# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::TruthSocial do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:truth_social) { client.truth_social }

  describe "#profile" do
    it "fetches a Truth Social profile successfully" do
      VCR.use_cassette("truth_social/profile_success") do
        profile = truth_social.profile("realDonaldTrump")

        assert_kind_of Hash, profile
        assert profile[:success]

        # Verify basic profile data
        assert_equal "realDonaldTrump", profile[:username]
        assert_equal "realDonaldTrump", profile[:acct]
        assert_equal "Donald J. Trump", profile[:display_name]
        assert profile[:verified]

        # Verify ID is present
        assert profile.key?(:id)
        refute_nil profile[:id]

        # Verify counts
        assert profile.key?(:followers_count)
        assert profile.key?(:following_count)
        assert profile.key?(:statuses_count)
        assert_predicate profile[:followers_count], :positive?

        # Verify URLs
        assert profile.key?(:url)
        assert profile.key?(:avatar)

        # Verify timestamps
        assert profile.key?(:created_at)
        assert profile.key?(:last_status_at)
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        truth_social.profile(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        truth_social.profile("")
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("truth_social/profile_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          truth_social.profile("thisuserdoesnotexist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("truth_social/profile_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.truth_social.profile("realDonaldTrump")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#user_posts" do
    it "fetches user posts by handle successfully" do
      VCR.use_cassette("truth_social/user_posts_success") do
        result = truth_social.user_posts(handle: "realDonaldTrump")

        assert_kind_of Hash, result
        assert result[:success]

        # Verify posts array exists
        assert result.key?(:posts)
        assert_kind_of Array, result[:posts]
        refute_empty result[:posts]

        # Verify post structure
        post = result[:posts].first

        assert post.key?(:id)
        assert post.key?(:text)
        assert post.key?(:created_at)
        assert post.key?(:url)
        assert post.key?(:content)

        # Verify account data
        assert post.key?(:account)
        assert_equal "realDonaldTrump", post[:account][:username]

        # Verify engagement metrics
        assert post.key?(:replies_count)
        assert post.key?(:reblogs_count)
        assert post.key?(:favourites_count)

        # Verify pagination info
        assert result.key?(:next_max_id)
      end
    end

    it "fetches user posts by user_id successfully" do
      VCR.use_cassette("truth_social/user_posts_by_user_id") do
        # Trump's user_id
        result = truth_social.user_posts(user_id: "107780257626128497")

        assert_kind_of Hash, result
        assert result[:success]
        assert result.key?(:posts)
        assert_kind_of Array, result[:posts]
        refute_empty result[:posts]
      end
    end

    it "raises ArgumentError when neither handle nor user_id is provided" do
      error = assert_raises(ArgumentError) do
        truth_social.user_posts
      end
      assert_match(/handle or user_id is required/, error.message)
    end

    it "raises ArgumentError when both handle and user_id are empty" do
      error = assert_raises(ArgumentError) do
        truth_social.user_posts(handle: "", user_id: "")
      end
      assert_match(/handle or user_id is required/, error.message)
    end

    it "raises NotFoundError for non-existent user" do
      VCR.use_cassette("truth_social/user_posts_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          truth_social.user_posts(handle: "thisuserdoesnotexist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("truth_social/user_posts_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.truth_social.user_posts(handle: "realDonaldTrump")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end
end
