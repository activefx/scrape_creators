# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Kick do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:kick) { client.kick }

  describe "#clip" do
    it "fetches a Kick clip successfully" do
      VCR.use_cassette("kick/clip_success") do
        result = kick.clip("https://kick.com/xqc/clips/clip_01JGJHB6CEVFCQRYTVPM8DW892")

        assert_kind_of Hash, result
        assert result.key?(:clip)

        clip = result[:clip]

        # Verify basic clip data
        assert clip.key?(:id)
        refute_nil clip[:id]

        assert clip.key?(:title)
        refute_nil clip[:title]

        # Verify view counts
        assert clip.key?(:views) || clip.key?(:view_count)

        # Verify duration
        assert clip.key?(:duration)
        assert_predicate clip[:duration], :positive? if clip[:duration]

        # Verify URLs
        assert clip.key?(:clip_url)
        assert clip.key?(:thumbnail_url)

        # Verify timestamps
        assert clip.key?(:created_at)

        # Verify category data
        assert clip.key?(:category)
        if clip[:category]
          assert clip[:category].key?(:id)
          assert clip[:category].key?(:name)
          assert clip[:category].key?(:slug)
        end

        # Verify creator data
        assert clip.key?(:creator)
        if clip[:creator]
          assert clip[:creator].key?(:id)
          assert clip[:creator].key?(:username)
          assert clip[:creator].key?(:slug)
        end

        # Verify channel data
        assert clip.key?(:channel)
        if clip[:channel]
          assert clip[:channel].key?(:id)
          assert clip[:channel].key?(:username)
          assert clip[:channel].key?(:slug)
        end
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        kick.clip(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        kick.clip("")
      end
      assert_match(/url is required/, error.message)
    end

    it "raises NotFoundError for non-existent clip" do
      VCR.use_cassette("kick/clip_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          kick.clip("https://kick.com/xqc/clips/nonexistent_clip_12345")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("kick/clip_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.kick.clip("https://kick.com/xqc/clips/clip_01JGJHB6CEVFCQRYTVPM8DW892")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end
end
