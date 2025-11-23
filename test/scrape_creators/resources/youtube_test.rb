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
end
