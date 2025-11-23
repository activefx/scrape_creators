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
end
