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

  describe "#posts" do
    it "fetches posts from an Instagram profile" do
      VCR.use_cassette("instagram/posts_success") do
        posts = instagram.posts("barstoolsports")

        assert_kind_of Hash, posts

        # Verify response structure
        assert posts.key?(:items)
        assert posts.key?(:num_results)
        assert posts.key?(:more_available)
        assert posts.key?(:user)
        assert_equal "ok", posts[:status]

        # Verify items array
        assert_kind_of Array, posts[:items]
        refute_empty posts[:items]

        # Verify first post structure
        post = posts[:items].first

        assert post.key?(:pk)
        assert post.key?(:id)
        assert post.key?(:code)
        assert post.key?(:media_type)
        assert post.key?(:taken_at)
        assert post.key?(:user)

        # Verify user info in post
        assert_equal "barstoolsports", post[:user][:username]
      end
    end

    it "fetches posts with trim parameter" do
      VCR.use_cassette("instagram/posts_trimmed") do
        posts = instagram.posts("barstoolsports", trim: true)

        assert_kind_of Hash, posts
        assert posts.key?(:items)
        assert_equal "ok", posts[:status]
      end
    end

    it "returns pagination cursor for more results" do
      VCR.use_cassette("instagram/posts_success") do
        posts = instagram.posts("barstoolsports")

        # If more_available is true, next_max_id should be present
        if posts[:more_available]
          assert posts.key?(:next_max_id)
          refute_nil posts[:next_max_id]
        end
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        instagram.posts(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        instagram.posts("")
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("instagram/posts_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          instagram.posts("thisuserdoesnotexist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("instagram/posts_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.instagram.posts("barstoolsports")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#post" do
    it "fetches Instagram post details successfully" do
      VCR.use_cassette("instagram/post_success") do
        result = instagram.post("https://www.instagram.com/reel/DF5s0duxDts/")

        assert_kind_of Hash, result

        # Verify response structure
        assert result.key?(:data)
        assert result[:data].key?(:xdt_shortcode_media)
        assert_equal "ok", result[:status]

        # Verify media data
        media = result[:data][:xdt_shortcode_media]

        assert media.key?(:id)
        assert media.key?(:shortcode)
        assert_equal "DF5s0duxDts", media[:shortcode]

        # Verify owner info
        assert media.key?(:owner)
        assert_equal "adrianhorning", media[:owner][:username]

        # Verify it's a video
        assert media[:is_video]
        assert media.key?(:video_url)
        assert media.key?(:video_duration)
      end
    end

    it "fetches post with trim parameter" do
      VCR.use_cassette("instagram/post_trimmed") do
        result = instagram.post("https://www.instagram.com/reel/DF5s0duxDts/", trim: true)

        assert_kind_of Hash, result
        assert result.key?(:data)
        assert_equal "ok", result[:status]
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        instagram.post(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        instagram.post("")
      end
      assert_match(/url is required/, error.message)
    end

    it "raises NotFoundError for non-existent post" do
      VCR.use_cassette("instagram/post_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          instagram.post("https://www.instagram.com/p/nonexistent123456789/")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("instagram/post_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.instagram.post("https://www.instagram.com/reel/DF5s0duxDts/")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#transcript" do
    it "fetches Instagram transcript successfully" do
      VCR.use_cassette("instagram/transcript_success") do
        result = instagram.transcript("https://www.instagram.com/reel/DHsD6HGqJhp/")

        assert_kind_of Hash, result
        assert result[:success]

        # Verify transcripts array structure
        assert result.key?(:transcripts)
        assert_kind_of Array, result[:transcripts]
        refute_empty result[:transcripts]

        # Verify first transcript structure
        transcript = result[:transcripts].first

        assert transcript.key?(:id)
        assert transcript.key?(:shortcode)
        assert transcript.key?(:text)
        assert_equal "DHsD6HGqJhp", transcript[:shortcode]
      end
    end

    it "handles transcript with no speech detected" do
      VCR.use_cassette("instagram/transcript_no_speech") do
        result = instagram.transcript("https://www.instagram.com/p/DI2UdChyFfP/")

        assert_kind_of Hash, result
        assert result[:success]
        assert result.key?(:transcripts)

        # Text may be null when no speech is detected
        transcript = result[:transcripts].first

        assert transcript.key?(:text)
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        instagram.transcript(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        instagram.transcript("")
      end
      assert_match(/url is required/, error.message)
    end

    it "raises NotFoundError for non-existent post" do
      VCR.use_cassette("instagram/transcript_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          instagram.transcript("https://www.instagram.com/p/nonexistent123456789/")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("instagram/transcript_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.instagram.transcript("https://www.instagram.com/reel/DHsD6HGqJhp/")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#search_reels" do
    it "searches for reels by keyword" do
      VCR.use_cassette("instagram/search_reels_success") do
        results = instagram.search_reels("running")

        assert_kind_of Hash, results
        assert results[:success]

        # Verify response structure
        assert results.key?(:reels)
        assert results.key?(:credits_remaining)
        assert_kind_of Array, results[:reels]
        refute_empty results[:reels]

        # Verify first reel structure
        reel = results[:reels].first

        assert reel.key?(:id)
        assert reel.key?(:shortcode)
        assert reel.key?(:url)
        assert reel.key?(:caption)
        assert reel.key?(:video_url)
        assert reel.key?(:video_duration)
        assert reel.key?(:video_view_count)
        assert reel.key?(:video_play_count)
        assert reel.key?(:is_video)
        assert reel.key?(:owner)
        assert reel.key?(:taken_at)
        assert reel.key?(:like_count)
        assert reel.key?(:comment_count)

        # Verify owner info
        owner = reel[:owner]

        assert owner.key?(:id)
        assert owner.key?(:username)
        assert owner.key?(:is_verified)
      end
    end

    it "searches for reels with amount parameter" do
      VCR.use_cassette("instagram/search_reels_with_amount") do
        results = instagram.search_reels("fitness", amount: 5)

        assert_kind_of Hash, results
        assert results[:success]
        assert results.key?(:reels)
        assert_kind_of Array, results[:reels]
      end
    end

    it "raises ArgumentError when query is nil" do
      error = assert_raises(ArgumentError) do
        instagram.search_reels(nil)
      end
      assert_match(/query is required/, error.message)
    end

    it "raises ArgumentError when query is empty" do
      error = assert_raises(ArgumentError) do
        instagram.search_reels("")
      end
      assert_match(/query is required/, error.message)
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("instagram/search_reels_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.instagram.search_reels("running")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#reels" do
    it "fetches reels from an Instagram profile by handle" do
      VCR.use_cassette("instagram/reels_by_handle_success") do
        reels = instagram.reels(handle: "adrianhorning")

        assert_kind_of Hash, reels

        # Verify response structure
        assert reels.key?(:items)
        assert reels.key?(:paging_info)
        assert_equal "ok", reels[:status]

        # Verify items array
        assert_kind_of Array, reels[:items]
        refute_empty reels[:items]

        # Verify first reel structure
        item = reels[:items].first

        assert item.key?(:media)
        media = item[:media]

        assert media.key?(:pk)
        assert media.key?(:id)
        assert media.key?(:code)
        assert media.key?(:taken_at)
        assert media.key?(:media_type)
        assert media.key?(:product_type)
        assert_equal "clips", media[:product_type]

        # Verify user info in reel
        assert media.key?(:user)
        assert_equal "adrianhorning", media[:user][:username]

        # Verify video properties
        assert media.key?(:video_duration)
        assert media.key?(:has_audio)
      end
    end

    it "fetches reels from an Instagram profile by user ID" do
      VCR.use_cassette("instagram/reels_by_user_id_success") do
        reels = instagram.reels(user_id: "2700692569")

        assert_kind_of Hash, reels

        # Verify response structure
        assert reels.key?(:items)
        assert reels.key?(:paging_info)
        assert_equal "ok", reels[:status]

        # Verify items array
        assert_kind_of Array, reels[:items]
        refute_empty reels[:items]
      end
    end

    it "accepts integer user ID" do
      VCR.use_cassette("instagram/reels_by_user_id_success") do
        reels = instagram.reels(user_id: 2_700_692_569)

        assert_kind_of Hash, reels
        assert reels.key?(:items)
      end
    end

    it "fetches reels with trim parameter" do
      VCR.use_cassette("instagram/reels_trimmed") do
        reels = instagram.reels(handle: "adrianhorning", trim: true)

        assert_kind_of Hash, reels
        assert reels.key?(:items)
        assert_equal "ok", reels[:status]
      end
    end

    it "returns pagination info for more results" do
      VCR.use_cassette("instagram/reels_by_handle_success") do
        reels = instagram.reels(handle: "adrianhorning")

        # Verify paging_info structure
        assert reels.key?(:paging_info)
        paging_info = reels[:paging_info]

        assert paging_info.key?(:more_available)

        # If more_available is true, max_id should be present
        if paging_info[:more_available]
          assert paging_info.key?(:max_id)
          refute_nil paging_info[:max_id]
        end
      end
    end

    it "raises ArgumentError when both user_id and handle are nil" do
      error = assert_raises(ArgumentError) do
        instagram.reels
      end
      assert_match(/Either user_id or handle is required/, error.message)
    end

    it "raises ArgumentError when both user_id and handle are empty" do
      error = assert_raises(ArgumentError) do
        instagram.reels(user_id: "", handle: "")
      end
      assert_match(/Either user_id or handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("instagram/reels_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          instagram.reels(handle: "thisuserdoesnotexist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("instagram/reels_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.instagram.reels(handle: "adrianhorning")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#comments" do
    it "fetches comments from an Instagram post" do
      VCR.use_cassette("instagram/comments_success") do
        result = instagram.comments("https://www.instagram.com/reel/DGg3aQqvOkv/")

        assert_kind_of Hash, result
        assert result[:success]

        # Verify response structure
        assert result.key?(:comments)
        assert result.key?(:num_comments_grabbed)
        assert result.key?(:credit_cost)
        assert_kind_of Array, result[:comments]
        refute_empty result[:comments]

        # Verify first comment structure
        comment = result[:comments].first

        assert comment.key?(:id)
        assert comment.key?(:text)
        assert comment.key?(:created_at)
        assert comment.key?(:user)

        # Verify user info in comment
        user = comment[:user]

        assert user.key?(:id)
        assert user.key?(:username)
        assert user.key?(:profile_pic_url)
      end
    end

    it "fetches comments with amount parameter" do
      VCR.use_cassette("instagram/comments_with_amount") do
        result = instagram.comments("https://www.instagram.com/reel/DGg3aQqvOkv/", amount: 30)

        assert_kind_of Hash, result
        assert result[:success]
        assert result.key?(:comments)
        assert_kind_of Array, result[:comments]
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        instagram.comments(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        instagram.comments("")
      end
      assert_match(/url is required/, error.message)
    end

    it "raises NotFoundError for non-existent post" do
      VCR.use_cassette("instagram/comments_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          instagram.comments("https://www.instagram.com/p/nonexistent123456789/")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("instagram/comments_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.instagram.comments("https://www.instagram.com/reel/DGg3aQqvOkv/")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end
end
