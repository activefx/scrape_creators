# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Tiktok do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:tiktok) { client.tiktok }

  describe "#profile" do
    it "fetches a TikTok profile successfully" do
      VCR.use_cassette("tiktok/profile_success") do
        profile = tiktok.profile("stoolpresidente")

        assert_kind_of Hash, profile
        assert profile.key?(:user)
        assert profile.key?(:stats)

        # Verify user data structure
        user = profile[:user]

        assert_equal "stoolpresidente", user[:unique_id]
        assert_equal "Dave Portnoy", user[:nickname]
        assert user[:verified]

        # Verify stats structure
        stats = profile[:stats]

        assert_predicate stats[:follower_count], :positive?
        assert_predicate stats[:video_count], :positive?
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        tiktok.profile(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        tiktok.profile("")
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("tiktok/profile_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          tiktok.profile("thisuserdoesnotexist123456789")
        end
      end
    end

    it "raises PaymentRequiredError when out of credits" do
      VCR.use_cassette("tiktok/profile_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        assert_raises(ScrapeCreators::PaymentRequiredError) do
          invalid_client.tiktok.profile("stoolpresidente")
        end
      end
    end
  end

  describe "#profile_videos" do
    it "fetches profile videos successfully" do
      VCR.use_cassette("tiktok/profile_videos_success") do
        videos = tiktok.profile_videos("stoolpresidente")

        assert_kind_of Hash, videos
        assert videos.key?(:aweme_list)
        assert_kind_of Array, videos[:aweme_list]

        unless videos[:aweme_list].empty?
          first_video = videos[:aweme_list].first

          assert first_video.key?(:aweme_id)
          assert first_video.key?(:desc)
          assert first_video.key?(:create_time)
        end
      end
    end

    it "fetches profile videos with sort_by parameter" do
      VCR.use_cassette("tiktok/profile_videos_oldest") do
        videos = tiktok.profile_videos("stoolpresidente", sort_by: "oldest")

        assert_kind_of Hash, videos
        assert videos.key?(:aweme_list)
      end
    end

    it "fetches profile videos with pagination cursor" do
      VCR.use_cassette("tiktok/profile_videos_paginated") do
        videos = tiktok.profile_videos("stoolpresidente", max_cursor: "123456")

        assert_kind_of Hash, videos
        assert videos.key?(:aweme_list)
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        tiktok.profile_videos(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        tiktok.profile_videos("")
      end
      assert_match(/handle is required/, error.message)
    end
  end

  describe "#profile_videos_paginated" do
    it "fetches profile videos with handle successfully" do
      VCR.use_cassette("tiktok/profile_videos_paginated_handle_success") do
        videos = tiktok.profile_videos_paginated(handle: "stoolpresidente")

        assert_kind_of Hash, videos
        assert videos.key?(:item_list)
        assert_kind_of Array, videos[:item_list]
      end
    end

    it "fetches profile videos with amount parameter" do
      VCR.use_cassette("tiktok/profile_videos_paginated_with_amount") do
        videos = tiktok.profile_videos_paginated(handle: "stoolpresidente", amount: 50)

        assert_kind_of Hash, videos
        assert videos.key?(:item_list)
      end
    end

    it "raises ArgumentError when both handle and user_id are nil" do
      error = assert_raises(ArgumentError) do
        tiktok.profile_videos_paginated
      end
      assert_match(/handle or user_id is required/, error.message)
    end
  end

  describe "#video" do
    it "fetches video info successfully" do
      VCR.use_cassette("tiktok/video_success") do
        video = tiktok.video("https://www.tiktok.com/@programming_hub/video/7340627334321491205")

        assert_kind_of Hash, video
        assert video.key?(:aweme_id)
        assert video.key?(:desc)
        assert video.key?(:video)
        assert video.key?(:author)
        assert video.key?(:statistics)
      end
    end

    it "fetches video info with transcript" do
      VCR.use_cassette("tiktok/video_with_transcript") do
        video = tiktok.video(
          "https://www.tiktok.com/@programming_hub/video/7340627334321491205",
          get_transcript: true
        )

        assert_kind_of Hash, video
        assert video.key?(:aweme_id)
      end
    end

    it "fetches video info with region parameter" do
      VCR.use_cassette("tiktok/video_with_region") do
        video = tiktok.video(
          "https://www.tiktok.com/@programming_hub/video/7340627334321491205",
          region: "US"
        )

        assert_kind_of Hash, video
        assert video.key?(:aweme_id)
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        tiktok.video(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        tiktok.video("")
      end
      assert_match(/url is required/, error.message)
    end

    it "raises NotFoundError for non-existent video" do
      VCR.use_cassette("tiktok/video_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          tiktok.video("https://www.tiktok.com/@user/video/1234567890")
        end
      end
    end
  end

  describe "#video_transcript" do
    it "fetches video transcript successfully" do
      VCR.use_cassette("tiktok/video_transcript_success") do
        transcript = tiktok.video_transcript("https://www.tiktok.com/@programming_hub/video/7340627334321491205")

        assert_kind_of Hash, transcript
      end
    end

    it "fetches video transcript with language parameter" do
      VCR.use_cassette("tiktok/video_transcript_with_language") do
        transcript = tiktok.video_transcript(
          "https://www.tiktok.com/@programming_hub/video/7340627334321491205",
          language: "es"
        )

        assert_kind_of Hash, transcript
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        tiktok.video_transcript(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        tiktok.video_transcript("")
      end
      assert_match(/url is required/, error.message)
    end
  end

  describe "#user_live" do
    it "fetches user live status successfully when live" do
      VCR.use_cassette("tiktok/user_live_active") do
        live = tiktok.user_live("someliveuser")

        assert_kind_of Hash, live
        assert live.key?(:live_room_user_info)
      end
    end

    it "fetches user live status successfully when not live" do
      VCR.use_cassette("tiktok/user_live_inactive") do
        live = tiktok.user_live("stoolpresidente")

        assert_kind_of Hash, live
        assert live.key?(:live_room_user_info)
        # When not live, live_room_user_info is an empty hash
        assert_equal({}, live[:live_room_user_info])
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        tiktok.user_live(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        tiktok.user_live("")
      end
      assert_match(/handle is required/, error.message)
    end
  end

  describe "#video_comments" do
    it "fetches video comments successfully" do
      VCR.use_cassette("tiktok/video_comments_success") do
        comments = tiktok.video_comments("https://www.tiktok.com/@programming_hub/video/7340627334321491205")

        assert_kind_of Hash, comments
        assert comments.key?(:comments)
        assert_kind_of Array, comments[:comments]

        unless comments[:comments].empty?
          first_comment = comments[:comments].first

          assert first_comment.key?(:cid)
          assert first_comment.key?(:text)
          assert first_comment.key?(:user)
        end
      end
    end

    it "fetches video comments with cursor pagination" do
      VCR.use_cassette("tiktok/video_comments_with_cursor") do
        comments = tiktok.video_comments(
          "https://www.tiktok.com/@programming_hub/video/7340627334321491205",
          cursor: "20"
        )

        assert_kind_of Hash, comments
        assert comments.key?(:comments)
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        tiktok.video_comments(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        tiktok.video_comments("")
      end
      assert_match(/url is required/, error.message)
    end
  end

  describe "#user_following" do
    it "fetches user following list successfully" do
      VCR.use_cassette("tiktok/user_following_success") do
        following = tiktok.user_following("stoolpresidente")

        assert_kind_of Hash, following
        assert following.key?(:followings)
        assert_kind_of Array, following[:followings]

        unless following[:followings].empty?
          first_following = following[:followings].first

          assert first_following.key?(:uid)
          assert first_following.key?(:unique_id)
          assert first_following.key?(:nickname)
        end
      end
    end

    it "fetches user following with pagination" do
      VCR.use_cassette("tiktok/user_following_with_pagination") do
        following = tiktok.user_following("stoolpresidente", min_time: 1_694_905_758)

        assert_kind_of Hash, following
        assert following.key?(:followings)
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        tiktok.user_following(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        tiktok.user_following("")
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent user" do
      VCR.use_cassette("tiktok/user_following_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          tiktok.user_following("thisuserdoesnotexist123456789")
        end
      end
    end
  end

  describe "#user_followers" do
    it "fetches user followers by handle successfully" do
      VCR.use_cassette("tiktok/user_followers_by_handle_success") do
        followers = tiktok.user_followers(handle: "stoolpresidente")

        assert_kind_of Hash, followers
        assert followers.key?(:followers)
        assert_kind_of Array, followers[:followers]

        unless followers[:followers].empty?
          first_follower = followers[:followers].first

          assert first_follower.key?(:uid)
          assert first_follower.key?(:unique_id)
          assert first_follower.key?(:nickname)
        end
      end
    end

    it "fetches user followers by user_id successfully" do
      VCR.use_cassette("tiktok/user_followers_by_user_id_success") do
        followers = tiktok.user_followers(user_id: "6659752019493208069")

        assert_kind_of Hash, followers
        assert followers.key?(:followers)
        assert_kind_of Array, followers[:followers]
      end
    end

    it "fetches user followers with pagination" do
      VCR.use_cassette("tiktok/user_followers_with_pagination") do
        followers = tiktok.user_followers(handle: "stoolpresidente", min_time: 1_737_751_140)

        assert_kind_of Hash, followers
        assert followers.key?(:followers)
      end
    end

    it "raises ArgumentError when both handle and user_id are nil" do
      error = assert_raises(ArgumentError) do
        tiktok.user_followers
      end
      assert_match(/handle or user_id is required/, error.message)
    end

    it "raises NotFoundError for non-existent user" do
      VCR.use_cassette("tiktok/user_followers_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          tiktok.user_followers(handle: "thisuserdoesnotexist123456789")
        end
      end
    end
  end

  describe "#search_users" do
    it "searches for users successfully" do
      VCR.use_cassette("tiktok/search_users_success") do
        results = tiktok.search_users("taylorswift")

        assert_kind_of Hash, results
        assert results.key?(:cursor)
        assert results.key?(:user_list)
        assert_kind_of Array, results[:user_list]

        unless results[:user_list].empty?
          first_user = results[:user_list].first

          assert first_user.key?(:user_info)

          user_info = first_user[:user_info]

          assert user_info.key?(:uid)
          assert user_info.key?(:unique_id)
          assert user_info.key?(:nickname)
        end
      end
    end

    it "searches for users with cursor pagination" do
      VCR.use_cassette("tiktok/search_users_with_cursor") do
        results = tiktok.search_users("taylorswift", cursor: 10)

        assert_kind_of Hash, results
        assert results.key?(:user_list)
      end
    end

    it "searches for users with trim parameter" do
      VCR.use_cassette("tiktok/search_users_with_trim") do
        results = tiktok.search_users("taylorswift", trim: true)

        assert_kind_of Hash, results
        # Trimmed responses use :users instead of :user_list
        assert results.key?(:users)
      end
    end

    it "raises ArgumentError when query is nil" do
      error = assert_raises(ArgumentError) do
        tiktok.search_users(nil)
      end
      assert_match(/query is required/, error.message)
    end

    it "raises ArgumentError when query is empty" do
      error = assert_raises(ArgumentError) do
        tiktok.search_users("")
      end
      assert_match(/query is required/, error.message)
    end
  end
end
