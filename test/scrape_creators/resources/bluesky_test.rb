# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Bluesky do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:bluesky) { client.bluesky }

  describe "#profile" do
    it "fetches a Bluesky profile successfully" do
      VCR.use_cassette("bluesky/profile_success") do
        profile = bluesky.profile("espn.com")

        assert_kind_of Hash, profile
        assert profile[:success]

        # Verify basic profile data
        assert_equal "espn.com", profile[:handle]
        assert_equal "ESPN", profile[:display_name]

        # Verify DID
        assert profile.key?(:did)
        assert profile[:did].start_with?("did:plc:")

        # Verify counts
        assert profile.key?(:followers_count)
        assert_predicate profile[:followers_count], :positive?
        assert profile.key?(:follows_count)
        assert profile.key?(:posts_count)

        # Verify avatar
        assert profile.key?(:avatar)

        # Verify description/bio
        assert profile.key?(:description)

        # Verify timestamps
        assert profile.key?(:created_at)
        assert profile.key?(:indexed_at)

        # Verify verification structure
        assert profile.key?(:verification)
        assert_kind_of Hash, profile[:verification]

        # Verify associated structure
        assert profile.key?(:associated)
        assert_kind_of Hash, profile[:associated]
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        bluesky.profile(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        bluesky.profile("")
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("bluesky/profile_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          bluesky.profile("thisuserdoesnotexist123456789xyz.bsky.social")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("bluesky/profile_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.bluesky.profile("espn.com")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end
end
