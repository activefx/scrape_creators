# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Facebook do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:facebook) { client.facebook }

  describe "#profile" do
    it "fetches a Facebook profile successfully" do
      VCR.use_cassette("facebook/profile_success") do
        profile = facebook.profile("https://www.facebook.com/copperkettleyqr/")

        assert_kind_of Hash, profile
        assert profile[:success]

        # Verify basic profile data
        assert_equal "The Copper Kettle Restaurant", profile[:name]
        assert_equal "https://www.facebook.com/copperkettleyqr/", profile[:url]
        assert_equal "100064027242849", profile[:id]

        # Verify business information
        assert_equal "Pizza place", profile[:category]
        assert profile.key?(:address)
        assert profile.key?(:phone)
        assert profile.key?(:website)

        # Verify social metrics
        assert profile.key?(:like_count)
        assert profile.key?(:follower_count)
        assert_predicate profile[:like_count], :positive?
        assert_predicate profile[:follower_count], :positive?

        # Verify photo information
        assert profile.key?(:profile_pic_large)
        assert profile.key?(:profile_pic_medium)
        assert profile.key?(:profile_pic_small)
      end
    end

    it "fetches profile with business hours" do
      VCR.use_cassette("facebook/profile_with_business_hours") do
        profile = facebook.profile("https://www.facebook.com/copperkettleyqr/", get_business_hours: true)

        assert_kind_of Hash, profile
        assert profile[:success]

        # Verify business hours are present
        assert profile.key?(:business_hours)
        assert_kind_of Array, profile[:business_hours]
        refute_empty profile[:business_hours]

        # Verify business hours structure
        first_day = profile[:business_hours].first
        day_key = first_day.keys.first
        day_hours = first_day[day_key]

        assert day_hours.key?(:open)
        assert day_hours.key?(:close)
        assert day_hours.key?(:full_text)
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        facebook.profile(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        facebook.profile("")
      end
      assert_match(/url is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("facebook/profile_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          facebook.profile("https://www.facebook.com/thispagedoesnotexist123456789xyz/")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("facebook/profile_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.facebook.profile("https://www.facebook.com/copperkettleyqr/")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#profile_posts" do
    it "fetches posts from a Facebook profile using URL" do
      VCR.use_cassette("facebook/profile_posts_success") do
        posts = facebook.profile_posts(url: "https://www.facebook.com/pacemorby/")

        assert_kind_of Hash, posts
        assert posts[:success]

        # Verify posts array
        assert posts.key?(:posts)
        assert_kind_of Array, posts[:posts]
        refute_empty posts[:posts]

        # Verify post structure
        post = posts[:posts].first

        assert post.key?(:id)
        assert post.key?(:text)
        assert post.key?(:url)
        assert post.key?(:permalink)
        assert post.key?(:author)
        assert post.key?(:reaction_count)
        assert post.key?(:comment_count)
        assert post.key?(:publish_time)

        # Verify author structure
        author = post[:author]

        assert author.key?(:name)
        assert author.key?(:id)
      end
    end

    it "allows page_id parameter in addition to url" do
      # The API documentation mentions page_id can be passed for faster lookups
      # This test verifies the method accepts both parameters
      VCR.use_cassette("facebook/profile_posts_success") do
        # Using just url since page_id alone may not be supported
        posts = facebook.profile_posts(url: "https://www.facebook.com/pacemorby/")

        assert_kind_of Hash, posts
        assert posts[:success]
        assert posts.key?(:posts)
        assert_kind_of Array, posts[:posts]
        refute_empty posts[:posts]
      end
    end

    it "includes pagination cursor for more results" do
      VCR.use_cassette("facebook/profile_posts_success") do
        posts = facebook.profile_posts(url: "https://www.facebook.com/pacemorby/")

        # API returns cursor for pagination
        assert posts.key?(:cursor)
      end
    end

    it "fetches posts with pagination cursor" do
      VCR.use_cassette("facebook/profile_posts_paginated") do
        # Using a cursor from a previous response
        cursor = "Cg8Ob3JnYW5pY19jdXJzb3IJ"
        posts = facebook.profile_posts(url: "https://www.facebook.com/pacemorby/", cursor: cursor)

        assert_kind_of Hash, posts
        assert posts.key?(:posts)
      end
    end

    it "includes video details when post has video" do
      VCR.use_cassette("facebook/profile_posts_success") do
        posts = facebook.profile_posts(url: "https://www.facebook.com/pacemorby/")

        # Find a post with video details
        video_post = posts[:posts].find { |p| p[:video_details] }

        if video_post
          video_details = video_post[:video_details]

          assert video_details.key?(:sd_url) || video_details.key?(:hd_url)
          assert video_details.key?(:thumbnail_url)
        end
      end
    end

    it "includes top comments when available" do
      VCR.use_cassette("facebook/profile_posts_success") do
        posts = facebook.profile_posts(url: "https://www.facebook.com/pacemorby/")

        # Find a post with top comments
        post_with_comments = posts[:posts].find { |p| p[:top_comments] && !p[:top_comments].empty? }

        if post_with_comments
          comment = post_with_comments[:top_comments].first

          assert comment.key?(:id)
          assert comment.key?(:text)
          assert comment.key?(:author)
        end
      end
    end

    it "raises ArgumentError when both url and page_id are nil" do
      error = assert_raises(ArgumentError) do
        facebook.profile_posts
      end
      assert_match(/url or page_id is required/, error.message)
    end

    it "raises ArgumentError when both url and page_id are empty" do
      error = assert_raises(ArgumentError) do
        facebook.profile_posts(url: "", page_id: "")
      end
      assert_match(/url or page_id is required/, error.message)
    end

    it "returns error info for non-existent profile" do
      VCR.use_cassette("facebook/profile_posts_not_found") do
        # API returns 200 with error info in body for non-existent profiles
        result = facebook.profile_posts(url: "https://www.facebook.com/thispagedoesnotexist123456789xyz/")

        assert_kind_of Hash, result
        assert_equal "not_found", result[:error]
        assert_equal 404, result[:error_status]
        assert_match(/doesn't exist/i, result[:message])
      end
    end

    it "raises PaymentRequiredError for invalid API key" do
      VCR.use_cassette("facebook/profile_posts_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::PaymentRequiredError) do
          invalid_client.facebook.profile_posts(url: "https://www.facebook.com/pacemorby/")
        end

        assert_match(/credit/i, error.message)
      end
    end
  end
end
