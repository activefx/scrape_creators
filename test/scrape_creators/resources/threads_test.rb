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

  describe "#user_posts" do
    it "fetches posts from a Threads user successfully" do
      VCR.use_cassette("threads/user_posts_success") do
        response = threads.user_posts("sportsillustrated")

        assert_kind_of Hash, response
        assert response[:success]

        # Verify posts array
        assert response.key?(:posts)
        assert_kind_of Array, response[:posts]
        refute_empty response[:posts]

        # Verify first post structure
        post = response[:posts].first

        # Basic post identifiers
        assert post.key?(:id)
        assert post.key?(:pk)
        assert post.key?(:code)

        # User info
        assert post.key?(:user)
        assert_kind_of Hash, post[:user]
        assert post[:user].key?(:username)
        assert post[:user].key?(:pk)

        # Post content
        assert post.key?(:caption)
        assert_kind_of Hash, post[:caption]
        assert post[:caption].key?(:text)

        # Engagement metrics
        assert post.key?(:like_count)
        assert_kind_of Integer, post[:like_count]

        # Media info
        assert post.key?(:media_type)
        assert post.key?(:taken_at)

        # Threads-specific info
        assert post.key?(:text_post_app_info)
        assert_kind_of Hash, post[:text_post_app_info]
      end
    end

    it "fetches trimmed posts when trim option is true" do
      VCR.use_cassette("threads/user_posts_trimmed") do
        response = threads.user_posts("sportsillustrated", trim: true)

        assert_kind_of Hash, response
        assert response[:success]
        assert response.key?(:posts)
        assert_kind_of Array, response[:posts]
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        threads.user_posts(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        threads.user_posts("")
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent user" do
      VCR.use_cassette("threads/user_posts_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          threads.user_posts("thisuserdoesnotexist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("threads/user_posts_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.threads.user_posts("sportsillustrated")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#post" do
    let(:post_url) { "https://www.threads.net/@trendspider/post/DIU8naHS6q_" }

    it "fetches a Threads post successfully" do
      VCR.use_cassette("threads/post_success") do
        response = threads.post(post_url)

        assert_kind_of Hash, response
        assert response[:success]

        # Verify post object
        assert response.key?(:post)
        post = response[:post]

        assert_kind_of Hash, post

        # Basic post identifiers
        assert post.key?(:id)
        assert post.key?(:pk)
        assert post.key?(:code)

        # User info
        assert post.key?(:user)
        assert_kind_of Hash, post[:user]
        assert post[:user].key?(:username)
        assert post[:user].key?(:pk)

        # Post content
        assert post.key?(:caption)
        assert_kind_of Hash, post[:caption]
        assert post[:caption].key?(:text)

        # Engagement metrics
        assert post.key?(:like_count)
        assert_kind_of Integer, post[:like_count]

        # Media info
        assert post.key?(:media_type)
        assert post.key?(:taken_at)

        # Threads-specific info
        assert post.key?(:text_post_app_info)
        assert_kind_of Hash, post[:text_post_app_info]

        # Verify comments array
        assert response.key?(:comments)
        assert_kind_of Array, response[:comments]

        # Verify related posts array
        assert response.key?(:related_posts)
        assert_kind_of Array, response[:related_posts]
      end
    end

    it "fetches trimmed post data when trim option is true" do
      VCR.use_cassette("threads/post_trimmed") do
        response = threads.post(post_url, trim: true)

        assert_kind_of Hash, response
        assert response[:success]
        assert response.key?(:post)
        assert_kind_of Hash, response[:post]
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        threads.post(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        threads.post("")
      end
      assert_match(/url is required/, error.message)
    end

    it "raises NotFoundError for non-existent post" do
      VCR.use_cassette("threads/post_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          threads.post("https://www.threads.net/@nonexistentuser/post/XXXXXXXXX")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("threads/post_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.threads.post(post_url)
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#search" do
    it "searches for posts by keyword successfully" do
      VCR.use_cassette("threads/search_success") do
        response = threads.search("basketball")

        assert_kind_of Hash, response
        assert response[:success]

        # Verify posts array
        assert response.key?(:posts)
        assert_kind_of Array, response[:posts]
        refute_empty response[:posts]

        # Verify first post structure
        post = response[:posts].first

        # Basic post identifiers
        assert post.key?(:id)
        assert post.key?(:pk)
        assert post.key?(:code)

        # User info
        assert post.key?(:user)
        assert_kind_of Hash, post[:user]
        assert post[:user].key?(:username)
        assert post[:user].key?(:pk)

        # Post content
        assert post.key?(:caption)
        assert_kind_of Hash, post[:caption]
        assert post[:caption].key?(:text)

        # Engagement metrics
        assert post.key?(:like_count)
        assert_kind_of Integer, post[:like_count]

        # Media info
        assert post.key?(:media_type)
        assert post.key?(:taken_at)

        # Threads-specific info
        assert post.key?(:text_post_app_info)
        assert_kind_of Hash, post[:text_post_app_info]
      end
    end

    it "searches with trimmed response when trim option is true" do
      VCR.use_cassette("threads/search_trimmed") do
        response = threads.search("basketball", trim: true)

        assert_kind_of Hash, response
        assert response[:success]
        assert response.key?(:posts)
        assert_kind_of Array, response[:posts]
      end
    end

    it "raises ArgumentError when query is nil" do
      error = assert_raises(ArgumentError) do
        threads.search(nil)
      end
      assert_match(/query is required/, error.message)
    end

    it "raises ArgumentError when query is empty" do
      error = assert_raises(ArgumentError) do
        threads.search("")
      end
      assert_match(/query is required/, error.message)
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("threads/search_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.threads.search("basketball")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end
end
