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
end
