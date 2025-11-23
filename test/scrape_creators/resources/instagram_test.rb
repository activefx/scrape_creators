# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Instagram do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:instagram) { client.instagram }

  describe "#profile" do
    it "fetches an Instagram profile successfully" do
      VCR.use_cassette("instagram/profile_success") do
        profile = instagram.profile("adrianhorning")

        assert_kind_of Hash, profile
        assert profile[:success]
        assert profile.key?(:data)
        assert profile[:data].key?(:user)

        # Verify user data structure
        user = profile[:data][:user]

        assert_equal "adrianhorning", user[:username]
        assert_equal "Adrian Horning", user[:full_name]
        assert user[:is_verified]

        # Verify follower counts
        assert user[:edge_followed_by].key?(:count)
        assert_predicate user[:edge_followed_by][:count], :positive?

        # Verify following counts
        assert user[:edge_follow].key?(:count)
        assert_predicate user[:edge_follow][:count], :positive?
      end
    end

    it "fetches profile with trim parameter" do
      VCR.use_cassette("instagram/profile_trimmed") do
        profile = instagram.profile("adrianhorning", trim: true)

        assert_kind_of Hash, profile
        assert profile[:success]
        assert profile.key?(:data)
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        instagram.profile(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        instagram.profile("")
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("instagram/profile_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          instagram.profile("thisuserdoesnotexist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("instagram/profile_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.instagram.profile("adrianhorning")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#basic_profile" do
    it "fetches a basic Instagram profile by user ID" do
      VCR.use_cassette("instagram/basic_profile_success") do
        profile = instagram.basic_profile("314216")

        assert_kind_of Hash, profile

        # Verify basic profile data structure
        assert_equal "zuck", profile[:username]
        assert_equal "314216", profile[:pk]
        assert_equal "314216", profile[:id]
        assert_equal "Mark Zuckerberg", profile[:full_name]
        assert profile[:is_verified]
        refute profile[:is_private]

        # Verify counts
        assert_predicate profile[:follower_count], :positive?
        assert_predicate profile[:following_count], :positive?
        assert_predicate profile[:media_count], :positive?

        # Verify profile picture URLs exist
        assert profile.key?(:profile_pic_url)
        assert profile.key?(:hd_profile_pic_url_info)
      end
    end

    it "accepts integer user ID" do
      VCR.use_cassette("instagram/basic_profile_success") do
        profile = instagram.basic_profile(314_216)

        assert_kind_of Hash, profile
        assert_equal "zuck", profile[:username]
      end
    end

    it "raises ArgumentError when user_id is nil" do
      error = assert_raises(ArgumentError) do
        instagram.basic_profile(nil)
      end
      assert_match(/user_id is required/, error.message)
    end

    it "raises ArgumentError when user_id is empty" do
      error = assert_raises(ArgumentError) do
        instagram.basic_profile("")
      end
      assert_match(/user_id is required/, error.message)
    end

    it "raises NotFoundError for non-existent user ID" do
      VCR.use_cassette("instagram/basic_profile_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          instagram.basic_profile("999999999999999999")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("instagram/basic_profile_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.instagram.basic_profile("314216")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end
end
