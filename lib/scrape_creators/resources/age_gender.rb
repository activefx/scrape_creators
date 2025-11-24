# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Age and Gender detection API resource
    #
    # Provides methods to detect age and gender from social media profile images
    # using AI analysis. The profile photo must have a clear face to get accurate results.
    #
    # @see https://docs.scrapecreators.com/v1/detect-age-gender Age and Gender API Documentation
    class AgeGender < Resource
      # Detect age and gender from a social profile
      #
      # Uses AI to analyze the profile image from a social media profile URL
      # and returns estimated age range, gender, and confidence scores.
      # The profile photo must have a clear face to get an accurate result.
      #
      # @param url [String] URL to the user's social profile
      # @return [Hash] Age and gender detection results
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the request parameters are invalid
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      # @raise [NotFoundError] If the profile is not found
      #
      # @example Detect age and gender from a social profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.age_gender.detect("https://www.tiktok.com/@username")
      #   puts "Age: #{result[:age_range][:low]}-#{result[:age_range][:high]}"
      #   puts "Gender: #{result[:gender]} (#{result[:confidence][:gender]}% confidence)"
      #
      # @example Response structure
      #   {
      #     age_range: {
      #       low: 23,
      #       high: 29
      #     },
      #     gender: "Male",
      #     confidence: {
      #       gender: 82.51082611083984
      #     }
      #   }
      def detect(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/detect-age-gender", url: url)
      end
    end
  end
end
