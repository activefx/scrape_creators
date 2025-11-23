# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # LinkedIn API resource
    #
    # Provides methods to interact with LinkedIn endpoints for scraping public profile data,
    # company pages, and posts.
    #
    # @see https://docs.scrapecreators.com/v1/linkedin LinkedIn API Documentation
    class Linkedin < Resource
      # Get a person's public LinkedIn profile
      #
      # Scrapes a public LinkedIn profile including user information, recent posts,
      # experience, education, articles, publications, projects, and recommendations.
      # Note: This only returns what's publicly available (what you see in an incognito browser).
      # LinkedIn doesn't return work history or job title publicly anymore.
      #
      # @param url [String] The URL of the LinkedIn profile to get
      # @return [Hash] Profile data including name, image, location, followers, about,
      #   recent posts, experience, education, articles, publications, projects,
      #   recommendations, and similar profiles
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a LinkedIn profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   profile = client.linkedin.profile("https://www.linkedin.com/in/samparr/")
      #   puts profile[:name]        # => "Sam Parr"
      #   puts profile[:location]    # => "Westport, Connecticut, United States"
      #   puts profile[:followers]   # => 64803
      #
      # @example Response structure
      #   {
      #     success: true,
      #     name: "Sam Parr",
      #     image: "https://media.licdn.com/...",
      #     location: "Westport, Connecticut, United States",
      #     followers: 64803,
      #     connections: "",
      #     about: "I founded The Hustle...",
      #     recent_posts: [
      #       {
      #         title: "...",
      #         activity_type: "Posted by Austen Allred",
      #         link: "https://www.linkedin.com/posts/...",
      #         image: "https://..."
      #       }
      #     ],
      #     experience: [
      #       {
      #         type: "Organization",
      #         name: "Hampton",
      #         url: "https://www.linkedin.com/company/myhampton",
      #         location: "Austin, Texas Metropolitan Area",
      #         member: {
      #           type: "OrganizationRole",
      #           description: "..."
      #         }
      #       }
      #     ],
      #     education: [
      #       {
      #         type: "EducationalOrganization",
      #         name: "Belmont University",
      #         url: "https://www.linkedin.com/school/belmont-university/",
      #         member: {
      #           type: "OrganizationRole",
      #           start_date: 2008,
      #           end_date: 2012
      #         }
      #       }
      #     ],
      #     articles: [
      #       {
      #         headline: "RANT: How to PROPERLY analyze risk",
      #         author: "Sam Parr",
      #         date_published: "2017-09-17T13:08:55.000+00:00",
      #         image: "https://...",
      #         article_body: "..."
      #       }
      #     ],
      #     publications: [
      #       {
      #         name: "How my partner and I created a unique company...",
      #         url: "http://online.wsj.com/..."
      #       }
      #     ],
      #     projects: [
      #       {
      #         name: "Hustle Con 2015",
      #         url: "https://...",
      #         date_range: "2015",
      #         description: "...",
      #         contributors: [
      #           { name: "Elizabeth Yin", link: "...", image: "..." }
      #         ]
      #       }
      #     ],
      #     activity: [
      #       {
      #         title: "...",
      #         activity_type: "Shared by Sam Parr",
      #         link: "https://...",
      #         image: "https://..."
      #       }
      #     ],
      #     recommendations: [
      #       {
      #         name: "Jackie M.",
      #         link: "https://...",
      #         image: "https://...",
      #         text: "\"I got to know Sam over 2 years...\""
      #       }
      #     ],
      #     similar_profiles: [
      #       {
      #         link: "https://...",
      #         name: "Steve Cody",
      #         image: "https://..."
      #       }
      #     ]
      #   }
      def profile(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/linkedin/profile", url: url)
      end

      # Get a LinkedIn company page
      #
      # Scrapes a public LinkedIn company page including company information, location,
      # employee count, funding details, similar pages, employees, and recent posts.
      #
      # @param url [String] The URL of the LinkedIn company page to get
      # @return [Hash] Company data including name, description, location, employee count,
      #   website, logo, slogan, industry, size, founded year, headquarters, type,
      #   specialties, funding, employees, posts, and similar pages
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the company is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a LinkedIn company page
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   company = client.linkedin.company("https://www.linkedin.com/company/shopify")
      #   puts company[:name]           # => "Shopify"
      #   puts company[:industry]       # => "Software Development"
      #   puts company[:employee_count] # => 23591
      #
      # @example Response structure
      #   {
      #     success: true,
      #     id: "784652",
      #     name: "Shopify",
      #     description: "Shopify is a leading global commerce company...",
      #     location: {
      #       city: "Ottawa",
      #       state: "ON",
      #       country: "CA"
      #     },
      #     employee_count: 23591,
      #     website: "https://www.shopify.com",
      #     logo: "https://media.licdn.com/...",
      #     cover_image: "https://media.licdn.com/...",
      #     slogan: "Make commerce better for everyone",
      #     similar_pages: [
      #       {
      #         link: "https://www.linkedin.com/company/airbnb",
      #         name: "Airbnb",
      #         image: "https://media.licdn.com/..."
      #       }
      #     ],
      #     industry: "Software Development",
      #     size: "10,001+ employees",
      #     founded: 2006,
      #     headquarters: "Ottawa, ON",
      #     type: "Public Company",
      #     specialties: ["ecommerce", "API", "applications", ...],
      #     funding: {
      #       number_of_rounds: 4,
      #       last_round: {
      #         type: "Series C",
      #         date: "2014-01-11T00:00:00.000Z",
      #         amount: "US$ 100.0M"
      #       },
      #       investors: [
      #         {
      #           name: "OMERS Ventures",
      #           crunchbase_url: "https://www.crunchbase.com/...",
      #           image: "https://media.licdn.com/..."
      #         }
      #       ]
      #     },
      #     employees: [
      #       {
      #         name: "Todd Jefferson",
      #         title: "Staff Software Developer at Shopify",
      #         link: "https://ca.linkedin.com/in/toddjefferson",
      #         image: "https://media.licdn.com/..."
      #       }
      #     ],
      #     posts: [
      #       {
      #         url: "https://www.linkedin.com/posts/...",
      #         date_published: "2025-05-23T15:17:41.770Z",
      #         text: "In the era of AI, design matters more than ever..."
      #       }
      #     ]
      #   }
      def company(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/linkedin/company", url: url)
      end
    end
  end
end
