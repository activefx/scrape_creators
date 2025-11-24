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

  describe "#clip" do
    let(:clip_url) { "https://clips.twitch.tv/CloudySavageMarjoramRuleFive--ErzsYbE7UWvgCMQ" }

    it "fetches a Twitch clip successfully" do
      VCR.use_cassette("twitch/clip_success") do
        result = twitch.clip(clip_url)

        assert_kind_of Array, result
        refute_empty result

        # First item contains the main clip data
        clip_response = result.first

        assert clip_response.key?(:data)
        assert clip_response[:data].key?(:clip)

        clip = clip_response[:data][:clip]

        # Verify basic clip data
        assert clip.key?(:id)
        refute_nil clip[:id]

        assert clip.key?(:slug)
        refute_nil clip[:slug]

        assert clip.key?(:url)
        refute_nil clip[:url]

        assert clip.key?(:title)
        refute_nil clip[:title]

        # Verify view count
        assert clip.key?(:view_count)
        assert_kind_of Integer, clip[:view_count]

        # Verify duration
        assert clip.key?(:duration_seconds)
        assert_kind_of Integer, clip[:duration_seconds]

        # Verify broadcaster info
        assert clip.key?(:broadcaster)
        broadcaster = clip[:broadcaster]

        assert broadcaster.key?(:id)
        assert broadcaster.key?(:login)
        assert broadcaster.key?(:display_name)

        # Verify video qualities
        assert clip.key?(:video_qualities)
        assert_kind_of Array, clip[:video_qualities]

        if clip[:video_qualities].any?
          quality = clip[:video_qualities].first

          assert quality.key?(:source_url)
        end

        # Verify video URL
        assert clip.key?(:video_url)
        refute_nil clip[:video_url]

        # Verify curator info (may be nil for some clips)
        assert clip.key?(:curator)

        # Verify game info
        assert clip.key?(:game)
        if clip[:game]
          assert clip[:game].key?(:id)
          assert clip[:game].key?(:name)
        end

        # Verify created_at timestamp
        assert clip.key?(:created_at)
        refute_nil clip[:created_at]
      end
    end

    it "returns related clips from broadcaster" do
      VCR.use_cassette("twitch/clip_success") do
        result = twitch.clip(clip_url)

        # Second item contains user clips data
        assert_operator result.length, :>=, 2
        user_response = result[1]

        assert user_response.key?(:data)
        assert user_response[:data].key?(:user)

        user = user_response[:data][:user]
        if user
          assert user.key?(:clips)
          assert user[:clips].key?(:edges)
          assert_kind_of Array, user[:clips][:edges]

          if user[:clips][:edges].any?
            edge = user[:clips][:edges].first

            assert edge.key?(:node)
            assert edge[:node].key?(:id)
            assert edge[:node].key?(:title)
            assert edge[:node].key?(:view_count)
          end
        end
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        twitch.clip(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        twitch.clip("")
      end
      assert_match(/url is required/, error.message)
    end

    it "raises NotFoundError for non-existent clip" do
      VCR.use_cassette("twitch/clip_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          twitch.clip("https://clips.twitch.tv/ThisClipDoesNotExist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("twitch/clip_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.twitch.clip(clip_url)
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end
end
