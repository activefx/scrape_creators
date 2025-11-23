# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::TruthSocial do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:truth_social) { client.truth_social }

  describe "#profile" do
    it "fetches a Truth Social profile successfully" do
      VCR.use_cassette("truth_social/profile_success") do
        profile = truth_social.profile("realDonaldTrump")

        assert_kind_of Hash, profile
        assert profile[:success]

        # Verify basic profile data
        assert_equal "realDonaldTrump", profile[:username]
        assert_equal "realDonaldTrump", profile[:acct]
        assert_equal "Donald J. Trump", profile[:display_name]
        assert profile[:verified]

        # Verify ID is present
        assert profile.key?(:id)
        refute_nil profile[:id]

        # Verify counts
        assert profile.key?(:followers_count)
        assert profile.key?(:following_count)
        assert profile.key?(:statuses_count)
        assert_predicate profile[:followers_count], :positive?

        # Verify URLs
        assert profile.key?(:url)
        assert profile.key?(:avatar)

        # Verify timestamps
        assert profile.key?(:created_at)
        assert profile.key?(:last_status_at)
      end
    end

    it "raises ArgumentError when handle is nil" do
      error = assert_raises(ArgumentError) do
        truth_social.profile(nil)
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises ArgumentError when handle is empty" do
      error = assert_raises(ArgumentError) do
        truth_social.profile("")
      end
      assert_match(/handle is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("truth_social/profile_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          truth_social.profile("thisuserdoesnotexist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("truth_social/profile_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.truth_social.profile("realDonaldTrump")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end
end
