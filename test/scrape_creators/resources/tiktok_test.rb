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
        assert_equal "stoolpresidente", user[:uniqueId]
        assert_equal "Dave Portnoy", user[:nickname]
        assert_equal true, user[:verified]

        # Verify stats structure
        stats = profile[:stats]
        assert stats[:followerCount] > 0
        assert stats[:videoCount] > 0
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

    it "raises UnauthorizedError with invalid API key" do
      VCR.use_cassette("tiktok/profile_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.tiktok.profile("stoolpresidente")
        end
      end
    end
  end
end
