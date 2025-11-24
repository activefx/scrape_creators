# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Snapchat do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:snapchat) { client.snapchat }

  describe "#profile" do
    it "fetches a Snapchat profile successfully" do
      VCR.use_cassette("snapchat/profile_success") do
        profile = snapchat.profile("zane")

        assert_kind_of Hash, profile
        assert profile[:success]

        # Verify user profile data exists
        assert profile.key?(:user_profile)
        user_profile = profile[:user_profile]

        refute_nil user_profile

        # Verify basic profile data
        assert_equal "zane", user_profile[:username]
        assert user_profile.key?(:title)
        refute_nil user_profile[:title]

        # Verify subscriber count
        assert user_profile.key?(:subscriber_count)
        refute_nil user_profile[:subscriber_count]

        # Verify bio
        assert user_profile.key?(:bio)

        # Verify profile picture
        assert user_profile.key?(:profile_picture_url)

        # Verify snapcode image URL
        assert user_profile.key?(:snapcode_image_url)

        # Verify badge
        assert user_profile.key?(:badge)

        # Verify highlight flags
        assert user_profile.key?(:has_curated_highlights)
        assert user_profile.key?(:has_spotlight_highlights)

        # Verify related accounts
        assert user_profile.key?(:related_accounts_info)
        assert_kind_of Array, user_profile[:related_accounts_info]

        if user_profile[:related_accounts_info].any?
          related_account = user_profile[:related_accounts_info].first

          assert related_account.key?(:public_profile_info)
          public_info = related_account[:public_profile_info]

          assert public_info.key?(:username)
          assert public_info.key?(:title)
        end

        # Verify curated highlights array
        assert profile.key?(:curated_highlights)
        assert_kind_of Array, profile[:curated_highlights]

        if profile[:curated_highlights].any?
          highlight = profile[:curated_highlights].first

          assert highlight.key?(:story_type)
          assert highlight.key?(:story_title)
          assert highlight.key?(:thumbnail_url)
          assert highlight.key?(:snap_list)
          assert_kind_of Array, highlight[:snap_list]
        end

        # Verify spotlight highlights array
        assert profile.key?(:spotlight_highlights)
        assert_kind_of Array, profile[:spotlight_highlights]

        # Verify spotlight story metadata
        assert profile.key?(:spotlight_story_metadata)
        assert_kind_of Array, profile[:spotlight_story_metadata]

        if profile[:spotlight_story_metadata].any?
          metadata = profile[:spotlight_story_metadata].first

          assert metadata.key?(:video_metadata)
          if metadata[:video_metadata]
            assert metadata[:video_metadata].key?(:name)
            assert metadata[:video_metadata].key?(:thumbnail_url)
          end
        end
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        snapchat.profile(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        snapchat.profile("")
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("snapchat/profile_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          snapchat.profile("thisuserdoesnotexist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("snapchat/profile_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.snapchat.profile("zane")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end
end
