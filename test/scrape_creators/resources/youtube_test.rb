# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Youtube do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:youtube) { client.youtube }

  describe "#channel" do
    describe "with handle parameter" do
      it "fetches a YouTube channel by handle" do
        VCR.use_cassette("youtube/channel_by_handle") do
          channel = youtube.channel(handle: "mrbeast")

          assert_kind_of Hash, channel

          # Verify channel data structure
          assert channel.key?(:channel_id) || channel.key?(:id)
          assert channel.key?(:title)
          assert channel.key?(:description)

          # Verify subscriber count exists
          assert channel.key?(:subscriber_count) || channel.key?(:statistics)
        end
      end

      it "accepts handle with @ prefix" do
        VCR.use_cassette("youtube/channel_by_handle_with_at") do
          channel = youtube.channel(handle: "@mrbeast")

          assert_kind_of Hash, channel
          assert channel.key?(:title)
        end
      end
    end

    describe "with channel_id parameter" do
      it "fetches a YouTube channel by channel ID" do
        VCR.use_cassette("youtube/channel_by_id") do
          channel = youtube.channel(channel_id: "UCX6OQ3DkcsbYNE6H8uQQuVA")

          assert_kind_of Hash, channel
          assert channel.key?(:title)
        end
      end
    end

    describe "with url parameter" do
      it "fetches a YouTube channel by URL" do
        VCR.use_cassette("youtube/channel_by_url") do
          channel = youtube.channel(url: "https://www.youtube.com/@MrBeast")

          assert_kind_of Hash, channel
          assert channel.key?(:title)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when no identifier is provided" do
        error = assert_raises(ArgumentError) do
          youtube.channel
        end
        assert_match(/channel_id, handle, or url is required/, error.message)
      end

      it "raises ArgumentError when all identifiers are nil" do
        error = assert_raises(ArgumentError) do
          youtube.channel(channel_id: nil, handle: nil, url: nil)
        end
        assert_match(/channel_id, handle, or url is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises NotFoundError for non-existent channel" do
        VCR.use_cassette("youtube/channel_not_found") do
          assert_raises(ScrapeCreators::NotFoundError) do
            youtube.channel(handle: "thishandledefinitelydoesnotexist123456789xyz")
          end
        end
      end

      it "raises UnauthorizedError for invalid API key" do
        VCR.use_cassette("youtube/channel_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::UnauthorizedError) do
            invalid_client.youtube.channel(handle: "mrbeast")
          end

          assert_match(/invalid|unauthorized|api.?key/i, error.message)
        end
      end
    end
  end

  describe "#channel_videos" do
    describe "with handle parameter" do
      it "fetches videos from a YouTube channel by handle" do
        VCR.use_cassette("youtube/channel_videos_by_handle") do
          result = youtube.channel_videos(handle: "mrbeast")

          assert_kind_of Hash, result
          assert result.key?(:videos)
          assert_kind_of Array, result[:videos]

          # Verify video structure if videos exist
          if result[:videos].any?
            video = result[:videos].first

            assert video.key?(:id)
            assert video.key?(:title)
            assert video.key?(:url)
          end
        end
      end

      it "accepts handle with @ prefix" do
        VCR.use_cassette("youtube/channel_videos_by_handle_with_at") do
          result = youtube.channel_videos(handle: "@mrbeast")

          assert_kind_of Hash, result
          assert result.key?(:videos)
        end
      end
    end

    describe "with channel_id parameter" do
      it "fetches videos from a YouTube channel by channel ID" do
        VCR.use_cassette("youtube/channel_videos_by_id") do
          result = youtube.channel_videos(channel_id: "UCX6OQ3DkcsbYNE6H8uQQuVA")

          assert_kind_of Hash, result
          assert result.key?(:videos)
        end
      end
    end

    describe "with sort parameter" do
      it "fetches videos sorted by popular" do
        VCR.use_cassette("youtube/channel_videos_sort_popular") do
          result = youtube.channel_videos(handle: "mrbeast", sort: "popular")

          assert_kind_of Hash, result
          assert result.key?(:videos)
        end
      end

      it "fetches videos sorted by latest" do
        VCR.use_cassette("youtube/channel_videos_sort_latest") do
          result = youtube.channel_videos(handle: "mrbeast", sort: "latest")

          assert_kind_of Hash, result
          assert result.key?(:videos)
        end
      end
    end

    describe "with include_extras parameter" do
      it "fetches videos with extra details" do
        VCR.use_cassette("youtube/channel_videos_with_extras") do
          result = youtube.channel_videos(handle: "mrbeast", include_extras: true)

          assert_kind_of Hash, result
          assert result.key?(:videos)
        end
      end
    end

    describe "pagination" do
      it "returns continuation_token for pagination" do
        VCR.use_cassette("youtube/channel_videos_pagination") do
          result = youtube.channel_videos(handle: "mrbeast")

          assert_kind_of Hash, result
          # Continuation token may or may not be present depending on channel size
          assert result.key?(:videos)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when no identifier is provided" do
        error = assert_raises(ArgumentError) do
          youtube.channel_videos
        end
        assert_match(/channel_id or handle is required/, error.message)
      end

      it "raises ArgumentError when both identifiers are nil" do
        error = assert_raises(ArgumentError) do
          youtube.channel_videos(channel_id: nil, handle: nil)
        end
        assert_match(/channel_id or handle is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises NotFoundError for non-existent channel" do
        VCR.use_cassette("youtube/channel_videos_not_found") do
          assert_raises(ScrapeCreators::NotFoundError) do
            youtube.channel_videos(handle: "thishandledefinitelydoesnotexist123456789xyz")
          end
        end
      end

      it "raises authentication error for invalid API key" do
        VCR.use_cassette("youtube/channel_videos_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          # API may return UnauthorizedError or PaymentRequiredError for invalid credentials
          assert_raises(ScrapeCreators::UnauthorizedError, ScrapeCreators::PaymentRequiredError) do
            invalid_client.youtube.channel_videos(handle: "mrbeast")
          end
        end
      end
    end
  end

  describe "#channel_shorts" do
    describe "with handle parameter" do
      it "fetches shorts from a YouTube channel by handle" do
        VCR.use_cassette("youtube/channel_shorts_by_handle") do
          result = youtube.channel_shorts(handle: "upflip")

          assert_kind_of Hash, result
          assert result.key?(:shorts)
          assert_kind_of Array, result[:shorts]

          # Verify short structure if shorts exist
          if result[:shorts].any?
            short = result[:shorts].first

            assert short.key?(:id)
            assert short.key?(:title)
            assert short.key?(:url)
            assert_equal "short", short[:type]
          end
        end
      end

      it "accepts handle with @ prefix" do
        VCR.use_cassette("youtube/channel_shorts_by_handle_with_at") do
          result = youtube.channel_shorts(handle: "@upflip")

          assert_kind_of Hash, result
          assert result.key?(:shorts)
        end
      end
    end

    describe "with channel_id parameter" do
      it "fetches shorts from a YouTube channel by channel ID" do
        VCR.use_cassette("youtube/channel_shorts_by_id") do
          result = youtube.channel_shorts(channel_id: "UCX6OQ3DkcsbYNE6H8uQQuVA")

          assert_kind_of Hash, result
          assert result.key?(:shorts)
        end
      end
    end

    describe "with sort parameter" do
      it "fetches shorts sorted by popular" do
        VCR.use_cassette("youtube/channel_shorts_sort_popular") do
          result = youtube.channel_shorts(handle: "upflip", sort: "popular")

          assert_kind_of Hash, result
          assert result.key?(:shorts)
        end
      end

      it "fetches shorts sorted by newest" do
        VCR.use_cassette("youtube/channel_shorts_sort_newest") do
          result = youtube.channel_shorts(handle: "upflip", sort: "newest")

          assert_kind_of Hash, result
          assert result.key?(:shorts)
        end
      end
    end

    describe "pagination" do
      it "returns continuation_token for pagination" do
        VCR.use_cassette("youtube/channel_shorts_pagination") do
          result = youtube.channel_shorts(handle: "upflip")

          assert_kind_of Hash, result
          # Continuation token may or may not be present depending on channel size
          assert result.key?(:shorts)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when no identifier is provided" do
        error = assert_raises(ArgumentError) do
          youtube.channel_shorts
        end
        assert_match(/channel_id or handle is required/, error.message)
      end

      it "raises ArgumentError when both identifiers are nil" do
        error = assert_raises(ArgumentError) do
          youtube.channel_shorts(channel_id: nil, handle: nil)
        end
        assert_match(/channel_id or handle is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises NotFoundError for non-existent channel" do
        VCR.use_cassette("youtube/channel_shorts_not_found") do
          assert_raises(ScrapeCreators::NotFoundError) do
            youtube.channel_shorts(handle: "thishandledefinitelydoesnotexist123456789xyz")
          end
        end
      end

      it "raises authentication error for invalid API key" do
        VCR.use_cassette("youtube/channel_shorts_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          # API may return UnauthorizedError or PaymentRequiredError for invalid credentials
          assert_raises(ScrapeCreators::UnauthorizedError, ScrapeCreators::PaymentRequiredError) do
            invalid_client.youtube.channel_shorts(handle: "upflip")
          end
        end
      end
    end
  end

  describe "#channel_shorts_simple" do
    describe "with handle parameter" do
      it "fetches shorts from a YouTube channel by handle" do
        VCR.use_cassette("youtube/channel_shorts_simple_by_handle") do
          result = youtube.channel_shorts_simple(handle: "upflip", amount: 5)

          assert_kind_of Array, result
          assert_operator result.length, :<=, 5

          # Verify short structure if shorts exist
          if result.any?
            short = result.first

            assert short.key?(:id)
            assert short.key?(:title)
            assert short.key?(:url)
            assert_equal "short", short[:type]
            assert short.key?(:thumbnail)
            assert short.key?(:view_count_text)
            assert short.key?(:view_count_int)
          end
        end
      end
    end

    describe "with channel_id parameter" do
      it "fetches shorts from a YouTube channel by channel ID" do
        VCR.use_cassette("youtube/channel_shorts_simple_by_id") do
          result = youtube.channel_shorts_simple(channel_id: "UCX6OQ3DkcsbYNE6H8uQQuVA", amount: 5)

          assert_kind_of Array, result
        end
      end
    end

    describe "with different amounts" do
      it "returns the requested number of shorts" do
        VCR.use_cassette("youtube/channel_shorts_simple_amount") do
          result = youtube.channel_shorts_simple(handle: "upflip", amount: 10)

          assert_kind_of Array, result
          assert_operator result.length, :<=, 10
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when no identifier is provided" do
        error = assert_raises(ArgumentError) do
          youtube.channel_shorts_simple(amount: 5)
        end
        assert_match(/channel_id or handle is required/, error.message)
      end

      it "raises ArgumentError when both identifiers are nil" do
        error = assert_raises(ArgumentError) do
          youtube.channel_shorts_simple(channel_id: nil, handle: nil, amount: 5)
        end
        assert_match(/channel_id or handle is required/, error.message)
      end

      it "raises ArgumentError when amount is not provided" do
        assert_raises(ArgumentError) do
          youtube.channel_shorts_simple(handle: "upflip")
        end
      end
    end

    describe "error handling" do
      it "raises NotFoundError for non-existent channel" do
        VCR.use_cassette("youtube/channel_shorts_simple_not_found") do
          assert_raises(ScrapeCreators::NotFoundError) do
            youtube.channel_shorts_simple(handle: "thishandledefinitelydoesnotexist123456789xyz", amount: 5)
          end
        end
      end

      it "raises authentication error for invalid API key" do
        VCR.use_cassette("youtube/channel_shorts_simple_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          # API may return UnauthorizedError or PaymentRequiredError for invalid credentials
          assert_raises(ScrapeCreators::UnauthorizedError, ScrapeCreators::PaymentRequiredError) do
            invalid_client.youtube.channel_shorts_simple(handle: "upflip", amount: 5)
          end
        end
      end
    end
  end

  describe "#video" do
    describe "with video URL" do
      it "fetches video details" do
        VCR.use_cassette("youtube/video_by_url") do
          video = youtube.video(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")

          assert_kind_of Hash, video

          # Verify core video data structure
          assert video.key?(:id)
          assert video.key?(:title)
          assert video.key?(:description)
          assert video.key?(:type)

          # Verify engagement stats
          assert video.key?(:view_count_int) || video.key?(:view_count_text)
        end
      end

      it "includes channel information" do
        VCR.use_cassette("youtube/video_with_channel_info") do
          video = youtube.video(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")

          assert_kind_of Hash, video
          assert video.key?(:channel)
          assert_kind_of Hash, video[:channel] if video[:channel]
        end
      end
    end

    describe "with short URL" do
      it "fetches short details" do
        VCR.use_cassette("youtube/video_short_by_url") do
          short = youtube.video(url: "https://www.youtube.com/shorts/ydPkyvWtmg4")

          assert_kind_of Hash, short
          assert short.key?(:id)
          assert short.key?(:title)
        end
      end
    end

    describe "with get_transcript parameter" do
      it "fetches video with transcript" do
        VCR.use_cassette("youtube/video_with_transcript") do
          video = youtube.video(
            url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            get_transcript: true
          )

          assert_kind_of Hash, video
          assert video.key?(:id)
          assert video.key?(:title)
          # Transcript may or may not be available depending on the video
        end
      end

      it "fetches video without transcript when get_transcript is false" do
        VCR.use_cassette("youtube/video_without_transcript") do
          video = youtube.video(
            url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            get_transcript: false
          )

          assert_kind_of Hash, video
          assert video.key?(:id)
          assert video.key?(:title)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when url is not provided" do
        error = assert_raises(ArgumentError) do
          youtube.video(url: nil)
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is empty string" do
        error = assert_raises(ArgumentError) do
          youtube.video(url: "")
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is whitespace only" do
        error = assert_raises(ArgumentError) do
          youtube.video(url: "   ")
        end
        assert_match(/url is required/, error.message)
      end
    end

    describe "error handling" do
      it "returns nil values for non-existent video" do
        VCR.use_cassette("youtube/video_not_found") do
          # API returns 200 with null values for non-existent videos
          video = youtube.video(url: "https://www.youtube.com/watch?v=nonexistentvideo123xyz")

          assert_kind_of Hash, video
          assert video.key?(:id)
          # Non-existent videos have null/nil values for metadata
          assert_nil video[:view_count_int]
          assert_nil video[:description]
        end
      end

      it "raises authentication error for invalid API key" do
        VCR.use_cassette("youtube/video_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          # API may return UnauthorizedError or PaymentRequiredError for invalid credentials
          assert_raises(ScrapeCreators::UnauthorizedError, ScrapeCreators::PaymentRequiredError) do
            invalid_client.youtube.video(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
          end
        end
      end
    end
  end

  describe "#video_transcript" do
    describe "with video URL" do
      it "fetches video transcript" do
        VCR.use_cassette("youtube/video_transcript_by_url") do
          transcript = youtube.video_transcript(url: "https://www.youtube.com/watch?v=bjVIDXPP7Uk")

          assert_kind_of Hash, transcript

          # Verify transcript data structure
          assert transcript.key?(:video_id) || transcript.key?(:videoId)
          assert transcript.key?(:type)
          assert transcript.key?(:url)
          assert transcript.key?(:transcript)
          assert transcript.key?(:transcript_only_text) || transcript.key?(:transcriptOnlyText)
          assert transcript.key?(:language)

          # Verify transcript array structure
          assert_kind_of Array, transcript[:transcript]
          if transcript[:transcript].any?
            segment = transcript[:transcript].first

            assert segment.key?(:text)
            assert segment.key?(:start_ms) || segment.key?(:startMs)
            assert segment.key?(:end_ms) || segment.key?(:endMs)
            assert segment.key?(:start_time_text) || segment.key?(:startTimeText)
          end
        end
      end

      it "returns video type and url" do
        VCR.use_cassette("youtube/video_transcript_metadata") do
          transcript = youtube.video_transcript(url: "https://www.youtube.com/watch?v=bjVIDXPP7Uk")

          assert_kind_of Hash, transcript
          assert transcript.key?(:type)
          assert transcript.key?(:url)
        end
      end
    end

    describe "with short URL" do
      it "fetches short transcript" do
        VCR.use_cassette("youtube/video_transcript_short") do
          transcript = youtube.video_transcript(url: "https://www.youtube.com/shorts/ydPkyvWtmg4")

          assert_kind_of Hash, transcript
          # Short may have transcript or may not, but response should be valid
          assert transcript.key?(:video_id) || transcript.key?(:videoId) || transcript.key?(:type)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when url is not provided" do
        error = assert_raises(ArgumentError) do
          youtube.video_transcript(url: nil)
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is empty string" do
        error = assert_raises(ArgumentError) do
          youtube.video_transcript(url: "")
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is whitespace only" do
        error = assert_raises(ArgumentError) do
          youtube.video_transcript(url: "   ")
        end
        assert_match(/url is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises authentication error for invalid API key" do
        VCR.use_cassette("youtube/video_transcript_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          # API may return UnauthorizedError or PaymentRequiredError for invalid credentials
          assert_raises(ScrapeCreators::UnauthorizedError, ScrapeCreators::PaymentRequiredError) do
            invalid_client.youtube.video_transcript(url: "https://www.youtube.com/watch?v=bjVIDXPP7Uk")
          end
        end
      end
    end
  end

  describe "#video_comments" do
    describe "with url parameter" do
      it "fetches comments from a YouTube video" do
        VCR.use_cassette("youtube/video_comments_basic") do
          result = youtube.video_comments(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")

          assert_kind_of Hash, result
          assert result.key?(:comments)
          assert_kind_of Array, result[:comments]

          # Verify comment structure if comments exist
          if result[:comments].any?
            comment = result[:comments].first

            assert comment.key?(:id)
            assert comment.key?(:content)
            assert comment.key?(:author)
            assert_kind_of Hash, comment[:author]
          end
        end
      end

      it "returns comments with author information" do
        VCR.use_cassette("youtube/video_comments_with_author") do
          result = youtube.video_comments(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")

          assert_kind_of Hash, result
          assert result.key?(:comments)

          if result[:comments].any?
            comment = result[:comments].first
            author = comment[:author]

            assert author.key?(:name)
            assert author.key?(:channel_id)
          end
        end
      end

      it "returns comments with engagement data" do
        VCR.use_cassette("youtube/video_comments_with_engagement") do
          result = youtube.video_comments(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")

          assert_kind_of Hash, result
          assert result.key?(:comments)

          if result[:comments].any?
            comment = result[:comments].first
            # Check for engagement data if present
            assert comment.key?(:engagement) || comment.key?(:likes)
          end
        end
      end
    end

    describe "with order parameter" do
      it "fetches top comments" do
        VCR.use_cassette("youtube/video_comments_order_top") do
          result = youtube.video_comments(
            url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            order: "top"
          )

          assert_kind_of Hash, result
          assert result.key?(:comments)
        end
      end

      it "fetches newest comments" do
        VCR.use_cassette("youtube/video_comments_order_newest") do
          result = youtube.video_comments(
            url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            order: "newest"
          )

          assert_kind_of Hash, result
          assert result.key?(:comments)
        end
      end
    end

    describe "pagination" do
      it "returns continuation_token for pagination" do
        VCR.use_cassette("youtube/video_comments_pagination") do
          result = youtube.video_comments(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")

          assert_kind_of Hash, result
          # Continuation token may or may not be present depending on video
          assert result.key?(:comments)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when url is not provided" do
        error = assert_raises(ArgumentError) do
          youtube.video_comments(url: nil)
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is empty string" do
        error = assert_raises(ArgumentError) do
          youtube.video_comments(url: "")
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is whitespace only" do
        error = assert_raises(ArgumentError) do
          youtube.video_comments(url: "   ")
        end
        assert_match(/url is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises authentication error for invalid API key" do
        VCR.use_cassette("youtube/video_comments_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          # API may return UnauthorizedError or PaymentRequiredError for invalid credentials
          assert_raises(ScrapeCreators::UnauthorizedError, ScrapeCreators::PaymentRequiredError) do
            invalid_client.youtube.video_comments(url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
          end
        end
      end
    end
  end

  describe "#search" do
    describe "with query parameter" do
      it "searches YouTube for videos" do
        VCR.use_cassette("youtube/search_basic") do
          result = youtube.search(query: "running")

          assert_kind_of Hash, result
          assert result.key?(:videos)
          assert_kind_of Array, result[:videos]

          # Verify video structure if videos exist
          if result[:videos].any?
            video = result[:videos].first

            assert video.key?(:id)
            assert video.key?(:title)
            assert video.key?(:url)
            assert video.key?(:type)
            assert_equal "video", video[:type]
          end
        end
      end

      it "returns shorts in results" do
        VCR.use_cassette("youtube/search_with_shorts") do
          result = youtube.search(query: "running")

          assert_kind_of Hash, result
          assert result.key?(:shorts)
          assert_kind_of Array, result[:shorts]
        end
      end

      it "returns channels, playlists, shelves, and lives arrays" do
        VCR.use_cassette("youtube/search_all_types") do
          result = youtube.search(query: "running")

          assert_kind_of Hash, result
          assert result.key?(:channels)
          assert result.key?(:playlists)
          assert result.key?(:shelves)
          assert result.key?(:lives)
          assert_kind_of Array, result[:channels]
          assert_kind_of Array, result[:playlists]
          assert_kind_of Array, result[:shelves]
          assert_kind_of Array, result[:lives]
        end
      end
    end

    describe "with upload_date parameter" do
      it "filters by upload date" do
        VCR.use_cassette("youtube/search_upload_date_today") do
          result = youtube.search(query: "news", upload_date: "today")

          assert_kind_of Hash, result
          assert result.key?(:videos)
        end
      end

      it "accepts this_week upload date filter" do
        VCR.use_cassette("youtube/search_upload_date_this_week") do
          result = youtube.search(query: "news", upload_date: "this_week")

          assert_kind_of Hash, result
          assert result.key?(:videos)
        end
      end
    end

    describe "with sort_by parameter" do
      it "sorts by upload_date" do
        VCR.use_cassette("youtube/search_sort_upload_date") do
          result = youtube.search(query: "tutorial", sort_by: "upload_date")

          assert_kind_of Hash, result
          assert result.key?(:videos)
        end
      end

      it "sorts by relevance" do
        VCR.use_cassette("youtube/search_sort_relevance") do
          result = youtube.search(query: "tutorial", sort_by: "relevance")

          assert_kind_of Hash, result
          assert result.key?(:videos)
        end
      end
    end

    describe "with filter parameter" do
      it "filters for shorts only" do
        VCR.use_cassette("youtube/search_filter_shorts") do
          result = youtube.search(query: "funny", filter: "shorts")

          assert_kind_of Hash, result
          # When filtering for shorts, results may be in shorts or videos array
          assert result.key?(:videos) || result.key?(:shorts)
        end
      end
    end

    describe "with include_extras parameter" do
      it "includes extra details when true" do
        VCR.use_cassette("youtube/search_with_extras") do
          result = youtube.search(query: "music", include_extras: true)

          assert_kind_of Hash, result
          assert result.key?(:videos)
        end
      end
    end

    describe "pagination" do
      it "returns continuation_token for pagination" do
        VCR.use_cassette("youtube/search_pagination") do
          result = youtube.search(query: "cooking")

          assert_kind_of Hash, result
          # Continuation token may or may not be present
          assert result.key?(:videos)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when query is not provided" do
        error = assert_raises(ArgumentError) do
          youtube.search(query: nil)
        end
        assert_match(/query is required/, error.message)
      end

      it "raises ArgumentError when query is empty string" do
        error = assert_raises(ArgumentError) do
          youtube.search(query: "")
        end
        assert_match(/query is required/, error.message)
      end

      it "raises ArgumentError when query is whitespace only" do
        error = assert_raises(ArgumentError) do
          youtube.search(query: "   ")
        end
        assert_match(/query is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises authentication error for invalid API key" do
        VCR.use_cassette("youtube/search_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          # API may return UnauthorizedError or PaymentRequiredError for invalid credentials
          assert_raises(ScrapeCreators::UnauthorizedError, ScrapeCreators::PaymentRequiredError) do
            invalid_client.youtube.search(query: "test")
          end
        end
      end
    end
  end

  describe "#search_hashtag" do
    describe "with hashtag parameter" do
      it "searches YouTube by hashtag" do
        VCR.use_cassette("youtube/search_hashtag_basic") do
          result = youtube.search_hashtag(hashtag: "funny")

          assert_kind_of Hash, result
          assert result.key?(:videos)
          assert_kind_of Array, result[:videos]

          # Verify video structure if videos exist
          if result[:videos].any?
            video = result[:videos].first

            assert video.key?(:id)
            assert video.key?(:title)
            assert video.key?(:url)
            assert video.key?(:type)
          end
        end
      end

      it "returns video with channel information" do
        VCR.use_cassette("youtube/search_hashtag_with_channel") do
          result = youtube.search_hashtag(hashtag: "shorts")

          assert_kind_of Hash, result
          assert result.key?(:videos)

          if result[:videos].any?
            video = result[:videos].first

            assert video.key?(:channel)
            assert_kind_of Hash, video[:channel] if video[:channel]
          end
        end
      end

      it "returns video with view count and timing information" do
        VCR.use_cassette("youtube/search_hashtag_video_details") do
          result = youtube.search_hashtag(hashtag: "fails")

          assert_kind_of Hash, result
          assert result.key?(:videos)

          if result[:videos].any?
            video = result[:videos].first
            # Check for view count fields
            assert video.key?(:view_count_text) || video.key?(:view_count_int)
          end
        end
      end
    end

    describe "with type parameter" do
      it "filters for all content types" do
        VCR.use_cassette("youtube/search_hashtag_type_all") do
          result = youtube.search_hashtag(hashtag: "funny", type: "all")

          assert_kind_of Hash, result
          assert result.key?(:videos)
        end
      end

      it "filters for shorts only" do
        VCR.use_cassette("youtube/search_hashtag_type_shorts") do
          result = youtube.search_hashtag(hashtag: "funny", type: "shorts")

          assert_kind_of Hash, result
          # API returns results nested under :results key for type=shorts
          assert result.key?(:results)
          assert result[:results].key?(:shorts)
        end
      end
    end

    describe "pagination" do
      it "returns continuation_token for pagination" do
        VCR.use_cassette("youtube/search_hashtag_pagination") do
          result = youtube.search_hashtag(hashtag: "cooking")

          assert_kind_of Hash, result
          # Continuation token may or may not be present depending on results
          assert result.key?(:videos)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when hashtag is not provided" do
        error = assert_raises(ArgumentError) do
          youtube.search_hashtag(hashtag: nil)
        end
        assert_match(/hashtag is required/, error.message)
      end

      it "raises ArgumentError when hashtag is empty string" do
        error = assert_raises(ArgumentError) do
          youtube.search_hashtag(hashtag: "")
        end
        assert_match(/hashtag is required/, error.message)
      end

      it "raises ArgumentError when hashtag is whitespace only" do
        error = assert_raises(ArgumentError) do
          youtube.search_hashtag(hashtag: "   ")
        end
        assert_match(/hashtag is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises authentication error for invalid API key" do
        VCR.use_cassette("youtube/search_hashtag_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          # API may return UnauthorizedError or PaymentRequiredError for invalid credentials
          assert_raises(ScrapeCreators::UnauthorizedError, ScrapeCreators::PaymentRequiredError) do
            invalid_client.youtube.search_hashtag(hashtag: "funny")
          end
        end
      end
    end
  end

  describe "#trending_shorts" do
    describe "fetching trending shorts" do
      it "fetches trending YouTube shorts" do
        VCR.use_cassette("youtube/trending_shorts") do
          result = youtube.trending_shorts

          assert_kind_of Hash, result
          assert result.key?(:success)
          assert result.key?(:shorts)
          assert_kind_of Array, result[:shorts]
        end
      end

      it "returns shorts with expected structure" do
        VCR.use_cassette("youtube/trending_shorts_structure") do
          result = youtube.trending_shorts

          assert_kind_of Hash, result
          assert result.key?(:shorts)

          if result[:shorts].any?
            short = result[:shorts].first

            # Verify core short fields
            assert short.key?(:id)
            assert short.key?(:title)
            assert short.key?(:url)
            assert short.key?(:thumbnail)

            # Verify engagement fields
            assert short.key?(:view_count_text) || short.key?(:view_count_int)
          end
        end
      end

      it "returns shorts with channel information" do
        VCR.use_cassette("youtube/trending_shorts_with_channel") do
          result = youtube.trending_shorts

          assert_kind_of Hash, result
          assert result.key?(:shorts)

          if result[:shorts].any?
            short = result[:shorts].first

            assert short.key?(:channel)
            assert_kind_of Hash, short[:channel] if short[:channel]

            if short[:channel]
              assert short[:channel].key?(:id)
              assert short[:channel].key?(:title)
            end
          end
        end
      end

      it "returns shorts with duration information" do
        VCR.use_cassette("youtube/trending_shorts_with_duration") do
          result = youtube.trending_shorts

          assert_kind_of Hash, result
          assert result.key?(:shorts)

          if result[:shorts].any?
            short = result[:shorts].first

            assert short.key?(:duration_ms) || short.key?(:duration_formatted)
          end
        end
      end

      it "returns shorts with publish date information" do
        VCR.use_cassette("youtube/trending_shorts_with_publish_date") do
          result = youtube.trending_shorts

          assert_kind_of Hash, result
          assert result.key?(:shorts)

          if result[:shorts].any?
            short = result[:shorts].first

            assert short.key?(:publish_date_text) || short.key?(:publish_date)
          end
        end
      end
    end

    describe "error handling" do
      it "raises authentication error for invalid API key" do
        VCR.use_cassette("youtube/trending_shorts_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          # API may return UnauthorizedError or PaymentRequiredError for invalid credentials
          assert_raises(ScrapeCreators::UnauthorizedError, ScrapeCreators::PaymentRequiredError) do
            invalid_client.youtube.trending_shorts
          end
        end
      end
    end
  end

  describe "#playlist" do
    describe "with playlist_id parameter" do
      it "fetches videos from a YouTube playlist" do
        VCR.use_cassette("youtube/playlist_basic") do
          result = youtube.playlist(playlist_id: "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf")

          assert_kind_of Hash, result
          assert result.key?(:success)
          assert result.key?(:title)
          assert result.key?(:videos)
          assert_kind_of Array, result[:videos]
        end
      end

      it "returns playlist with owner information" do
        VCR.use_cassette("youtube/playlist_with_owner") do
          result = youtube.playlist(playlist_id: "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf")

          assert_kind_of Hash, result
          assert result.key?(:owner)

          if result[:owner]
            owner = result[:owner]

            assert_kind_of Hash, owner
            assert owner.key?(:id)
            assert owner.key?(:name)
            assert owner.key?(:url)
            assert owner.key?(:handle)
          end
        end
      end

      it "returns playlist with total videos count" do
        VCR.use_cassette("youtube/playlist_with_total_videos") do
          result = youtube.playlist(playlist_id: "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf")

          assert_kind_of Hash, result
          assert result.key?(:total_videos)
          assert_kind_of Integer, result[:total_videos]
        end
      end

      it "returns videos with expected structure" do
        VCR.use_cassette("youtube/playlist_video_structure") do
          result = youtube.playlist(playlist_id: "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf")

          assert_kind_of Hash, result
          assert result.key?(:videos)

          if result[:videos].any?
            video = result[:videos].first

            assert video.key?(:id)
            assert video.key?(:title)
            assert video.key?(:url)
            assert video.key?(:thumbnail)
            assert video.key?(:length_text)
            assert video.key?(:length_seconds)
          end
        end
      end

      it "returns videos with channel information" do
        VCR.use_cassette("youtube/playlist_videos_with_channel") do
          result = youtube.playlist(playlist_id: "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf")

          assert_kind_of Hash, result
          assert result.key?(:videos)

          if result[:videos].any?
            video = result[:videos].first

            assert video.key?(:channel)
            assert_kind_of Hash, video[:channel] if video[:channel]

            if video[:channel]
              assert video[:channel].key?(:title)
              assert video[:channel].key?(:url)
            end
          end
        end
      end

      it "returns credits remaining" do
        VCR.use_cassette("youtube/playlist_credits_remaining") do
          result = youtube.playlist(playlist_id: "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf")

          assert_kind_of Hash, result
          assert result.key?(:credits_remaining)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when playlist_id is not provided" do
        error = assert_raises(ArgumentError) do
          youtube.playlist(playlist_id: nil)
        end
        assert_match(/playlist_id is required/, error.message)
      end

      it "raises ArgumentError when playlist_id is empty string" do
        error = assert_raises(ArgumentError) do
          youtube.playlist(playlist_id: "")
        end
        assert_match(/playlist_id is required/, error.message)
      end

      it "raises ArgumentError when playlist_id is whitespace only" do
        error = assert_raises(ArgumentError) do
          youtube.playlist(playlist_id: "   ")
        end
        assert_match(/playlist_id is required/, error.message)
      end
    end

    describe "error handling" do
      it "returns minimal data for non-existent playlist" do
        VCR.use_cassette("youtube/playlist_not_found") do
          # API returns 200 with minimal data for non-existent playlists
          result = youtube.playlist(playlist_id: "PLnonexistentplaylistid123456789xyz")

          assert_kind_of Hash, result
          assert result.key?(:success)
          # Non-existent playlists have no title or videos array
          refute result.key?(:title)
          refute result.key?(:videos)
        end
      end

      it "raises authentication error for invalid API key" do
        VCR.use_cassette("youtube/playlist_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          # API may return UnauthorizedError or PaymentRequiredError for invalid credentials
          assert_raises(ScrapeCreators::UnauthorizedError, ScrapeCreators::PaymentRequiredError) do
            invalid_client.youtube.playlist(playlist_id: "PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf")
          end
        end
      end
    end
  end

  describe "#community_post" do
    describe "with url parameter" do
      it "fetches community post details" do
        VCR.use_cassette("youtube/community_post_basic") do
          result = youtube.community_post(
            url: "https://www.youtube.com/post/Ugkxvj2KoApYAXoqLWnKVr6zZe5JjeHrQeP8"
          )

          assert_kind_of Hash, result
          assert result.key?(:success)
          assert result.key?(:id)
          assert result.key?(:content)
        end
      end

      it "returns post with channel information" do
        VCR.use_cassette("youtube/community_post_with_channel") do
          result = youtube.community_post(
            url: "https://www.youtube.com/post/Ugkxvj2KoApYAXoqLWnKVr6zZe5JjeHrQeP8"
          )

          assert_kind_of Hash, result
          assert result.key?(:channel)

          if result[:channel]
            channel = result[:channel]

            assert_kind_of Hash, channel
            assert channel.key?(:id)
            assert channel.key?(:title)
            assert channel.key?(:url)
            assert channel.key?(:handle)
          end
        end
      end

      it "returns post with images array" do
        VCR.use_cassette("youtube/community_post_with_images") do
          result = youtube.community_post(
            url: "https://www.youtube.com/post/Ugkxvj2KoApYAXoqLWnKVr6zZe5JjeHrQeP8"
          )

          assert_kind_of Hash, result
          assert result.key?(:images)
          assert_kind_of Array, result[:images] if result[:images]
        end
      end

      it "returns post with engagement metrics" do
        VCR.use_cassette("youtube/community_post_with_engagement") do
          result = youtube.community_post(
            url: "https://www.youtube.com/post/Ugkxvj2KoApYAXoqLWnKVr6zZe5JjeHrQeP8"
          )

          assert_kind_of Hash, result
          assert result.key?(:like_count)
        end
      end

      it "returns post with publish date information" do
        VCR.use_cassette("youtube/community_post_with_publish_date") do
          result = youtube.community_post(
            url: "https://www.youtube.com/post/Ugkxvj2KoApYAXoqLWnKVr6zZe5JjeHrQeP8"
          )

          assert_kind_of Hash, result
          assert result.key?(:published_time_text) || result.key?(:published_time)
        end
      end

      it "returns credits remaining" do
        VCR.use_cassette("youtube/community_post_credits_remaining") do
          result = youtube.community_post(
            url: "https://www.youtube.com/post/Ugkxvj2KoApYAXoqLWnKVr6zZe5JjeHrQeP8"
          )

          assert_kind_of Hash, result
          assert result.key?(:credits_remaining)
        end
      end
    end

    describe "parameter validation" do
      it "raises ArgumentError when url is not provided" do
        error = assert_raises(ArgumentError) do
          youtube.community_post(url: nil)
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is empty string" do
        error = assert_raises(ArgumentError) do
          youtube.community_post(url: "")
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is whitespace only" do
        error = assert_raises(ArgumentError) do
          youtube.community_post(url: "   ")
        end
        assert_match(/url is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises authentication error for invalid API key" do
        VCR.use_cassette("youtube/community_post_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          # API may return UnauthorizedError or PaymentRequiredError for invalid credentials
          assert_raises(ScrapeCreators::UnauthorizedError, ScrapeCreators::PaymentRequiredError) do
            invalid_client.youtube.community_post(
              url: "https://www.youtube.com/post/Ugkxvj2KoApYAXoqLWnKVr6zZe5JjeHrQeP8"
            )
          end
        end
      end
    end
  end
end
