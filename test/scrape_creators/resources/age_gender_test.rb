# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::AgeGender do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:age_gender) { client.age_gender }

  describe "#detect" do
    let(:profile_url) { "https://www.tiktok.com/@charlidamelio" }

    it "detects age and gender successfully" do
      VCR.use_cassette("age_gender/detect_success") do
        result = age_gender.detect(profile_url)

        assert_kind_of Hash, result
      end
    end

    it "returns age_range with low and high values" do
      VCR.use_cassette("age_gender/detect_success") do
        result = age_gender.detect(profile_url)

        assert result.key?(:age_range)
        assert_kind_of Hash, result[:age_range]
        assert result[:age_range].key?(:low)
        assert result[:age_range].key?(:high)
        assert_kind_of Integer, result[:age_range][:low]
        assert_kind_of Integer, result[:age_range][:high]
      end
    end

    it "returns gender field" do
      VCR.use_cassette("age_gender/detect_success") do
        result = age_gender.detect(profile_url)

        assert result.key?(:gender)
        assert_includes %w[Male Female], result[:gender]
      end
    end

    it "returns confidence scores" do
      VCR.use_cassette("age_gender/detect_success") do
        result = age_gender.detect(profile_url)

        assert result.key?(:confidence)
        assert_kind_of Hash, result[:confidence]
        assert result[:confidence].key?(:gender)
        assert_kind_of Numeric, result[:confidence][:gender]
      end
    end

    describe "argument validation" do
      it "raises ArgumentError when url is nil" do
        error = assert_raises(ArgumentError) do
          age_gender.detect(nil)
        end
        assert_match(/url is required/, error.message)
      end

      it "raises ArgumentError when url is empty" do
        error = assert_raises(ArgumentError) do
          age_gender.detect("")
        end
        assert_match(/url is required/, error.message)
      end
    end

    describe "error handling" do
      it "raises PaymentRequiredError for invalid API key" do
        VCR.use_cassette("age_gender/detect_unauthorized") do
          invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

          error = assert_raises(ScrapeCreators::PaymentRequiredError) do
            invalid_client.age_gender.detect(profile_url)
          end

          assert_match(/credits/i, error.message)
        end
      end
    end
  end
end
