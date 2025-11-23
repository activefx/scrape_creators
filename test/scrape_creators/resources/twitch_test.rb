# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Twitch do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:twitch) { client.twitch }

  describe "#profile" do
    it "fetches a Twitch profile successfully" do
      VCR.use_cassette("twitch/profile_success") do
        profile = twitch.profile("ninja")

        assert_kind_of Hash, profile
        assert profile[:success]

        # Verify basic profile data
        assert_equal "ninja", profile[:handle]
        assert_equal "Ninja", profile[:display_name]

        # Verify ID is present
        assert profile.key?(:id)
        refute_nil profile[:id]

        # Verify follower count
        assert profile.key?(:followers)
        assert_predicate profile[:followers], :positive?

        # Verify description
        assert profile.key?(:description)

        # Verify social links are present (may be nil for some users)
        assert profile.key?(:instagram)
        assert profile.key?(:x)
        assert profile.key?(:tiktok)

        # Verify videos array
        assert profile.key?(:all_videos)
        assert_kind_of Array, profile[:all_videos]

        if profile[:all_videos].any?
          video = profile[:all_videos].first

          assert video.key?(:id)
          assert video.key?(:title)
          assert video.key?(:length_seconds)
          assert video.key?(:view_count)
        end

        # Verify featured clips array
        assert profile.key?(:featured_clips)
        assert_kind_of Array, profile[:featured_clips]

        if profile[:featured_clips].any?
          clip = profile[:featured_clips].first

          assert clip.key?(:id)
          assert clip.key?(:clip_title)
          assert clip.key?(:duration_seconds)
        end

        # Verify similar streamers array
        assert profile.key?(:similar_streamers)
        assert_kind_of Array, profile[:similar_streamers]

        if profile[:similar_streamers].any?
          streamer = profile[:similar_streamers].first

          assert streamer.key?(:id)
          assert streamer.key?(:display_name)
          assert streamer.key?(:login)
        end
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        twitch.profile(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        twitch.profile("")
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("twitch/profile_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          twitch.profile("thisuserdoesnotexist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("twitch/profile_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.twitch.profile("ninja")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end
end
