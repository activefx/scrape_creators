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
end
