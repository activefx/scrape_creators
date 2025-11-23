# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Threads do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:threads) { client.threads }

  describe "#profile" do
    it "fetches a Threads profile successfully" do
      VCR.use_cassette("threads/profile_success") do
        profile = threads.profile("sportsillustrated")

        assert_kind_of Hash, profile
        assert profile[:success]

        # Verify basic profile data
        assert_equal "sportsillustrated", profile[:username]
        assert_equal "Sports Illustrated", profile[:full_name]
        assert profile[:is_verified]

        # Verify ID fields
        assert profile.key?(:pk)
        assert profile.key?(:id)
        assert_equal profile[:pk], profile[:id]

        # Verify follower count
        assert profile.key?(:follower_count)
        assert_predicate profile[:follower_count], :positive?

        # Verify profile picture URLs
        assert profile.key?(:profile_pic_url)
        assert profile.key?(:hd_profile_pic_versions)
        assert_kind_of Array, profile[:hd_profile_pic_versions]

        # Verify biography
        assert profile.key?(:biography)
        assert profile.key?(:text_app_biography)

        # Verify bio links
        assert profile.key?(:bio_links)
        assert_kind_of Array, profile[:bio_links]

        # Verify Threads-specific fields
        refute_nil profile[:text_post_app_is_private]
        assert_includes [true, false], profile[:show_text_post_app_badge]
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        threads.profile(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        threads.profile("")
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("threads/profile_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          threads.profile("thisuserdoesnotexist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("threads/profile_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.threads.profile("sportsillustrated")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end
end
