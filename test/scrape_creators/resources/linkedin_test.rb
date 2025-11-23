# frozen_string_literal: true

require "test_helper"

describe ScrapeCreators::Resources::Linkedin do
  let(:api_key) { ENV.fetch("SCRAPE_CREATORS_API_KEY", "test_api_key") }
  let(:client) { ScrapeCreators::Client.new(api_key: api_key) }
  let(:linkedin) { client.linkedin }

  describe "#profile" do
    it "fetches a LinkedIn profile successfully" do
      VCR.use_cassette("linkedin/profile_success") do
        profile = linkedin.profile("https://www.linkedin.com/in/samparr/")

        assert_kind_of Hash, profile
        assert profile[:success]

        # Verify basic profile data
        assert_equal "Sam Parr", profile[:name]
        assert profile.key?(:image)
        assert profile.key?(:location)
        assert profile.key?(:followers)
        assert profile.key?(:about)

        # Verify recent posts structure
        assert profile.key?(:recent_posts)
        assert_kind_of Array, profile[:recent_posts]

        if profile[:recent_posts].any?
          post = profile[:recent_posts].first

          assert post.key?(:title)
          assert post.key?(:activity_type)
          assert post.key?(:link)
        end

        # Verify experience structure
        assert profile.key?(:experience)
        assert_kind_of Array, profile[:experience]

        if profile[:experience].any?
          exp = profile[:experience].first

          assert exp.key?(:name)
        end

        # Verify education structure
        assert profile.key?(:education)
        assert_kind_of Array, profile[:education]

        if profile[:education].any?
          edu = profile[:education].first

          assert edu.key?(:name)
        end
      end
    end

    it "fetches profile with articles and publications" do
      VCR.use_cassette("linkedin/profile_success") do
        profile = linkedin.profile("https://www.linkedin.com/in/samparr/")

        # Verify articles structure
        assert profile.key?(:articles)
        assert_kind_of Array, profile[:articles]

        if profile[:articles].any?
          article = profile[:articles].first

          assert article.key?(:headline)
          assert article.key?(:author)
        end

        # Verify publications structure
        assert profile.key?(:publications)
        assert_kind_of Array, profile[:publications]

        if profile[:publications].any?
          pub = profile[:publications].first

          assert pub.key?(:name)
          assert pub.key?(:url)
        end
      end
    end

    it "fetches profile with projects and recommendations" do
      VCR.use_cassette("linkedin/profile_success") do
        profile = linkedin.profile("https://www.linkedin.com/in/samparr/")

        # Verify projects structure
        assert profile.key?(:projects)
        assert_kind_of Array, profile[:projects]

        if profile[:projects].any?
          project = profile[:projects].first

          assert project.key?(:name)
        end

        # Verify recommendations structure
        assert profile.key?(:recommendations)
        assert_kind_of Array, profile[:recommendations]

        if profile[:recommendations].any?
          rec = profile[:recommendations].first

          assert rec.key?(:name)
          assert rec.key?(:text)
        end

        # Verify similar profiles structure
        assert profile.key?(:similar_profiles)
        assert_kind_of Array, profile[:similar_profiles]
      end
    end

    it "fetches profile with activity" do
      VCR.use_cassette("linkedin/profile_success") do
        profile = linkedin.profile("https://www.linkedin.com/in/samparr/")

        # Verify activity structure
        assert profile.key?(:activity)
        assert_kind_of Array, profile[:activity]

        if profile[:activity].any?
          activity = profile[:activity].first

          assert activity.key?(:title)
          assert activity.key?(:activity_type)
          assert activity.key?(:link)
        end
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        linkedin.profile(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        linkedin.profile("")
      end
      assert_match(/url is required/, error.message)
    end

    it "raises NotFoundError for non-existent profile" do
      VCR.use_cassette("linkedin/profile_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          linkedin.profile("https://www.linkedin.com/in/thisuserdoesnotexist123456789xyz/")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("linkedin/profile_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.linkedin.profile("https://www.linkedin.com/in/samparr/")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end

  describe "#company" do
    it "fetches a LinkedIn company page successfully" do
      VCR.use_cassette("linkedin/company_success") do
        company = linkedin.company("https://www.linkedin.com/company/shopify")

        assert_kind_of Hash, company
        assert company[:success]

        # Verify basic company data
        assert_equal "Shopify", company[:name]
        assert company.key?(:id)
        assert company.key?(:description)
        assert company.key?(:website)
        assert company.key?(:logo)

        # Verify location structure
        assert company.key?(:location)
        assert_kind_of Hash, company[:location]
        assert company[:location].key?(:city)
        assert company[:location].key?(:country)

        # Verify numeric fields
        assert company.key?(:employee_count)
        assert_kind_of Integer, company[:employee_count]
        assert_predicate company[:employee_count], :positive?

        # Verify company details
        assert company.key?(:industry)
        assert company.key?(:size)
        assert company.key?(:type)
        assert company.key?(:headquarters)
      end
    end

    it "fetches company with founding and slogan info" do
      VCR.use_cassette("linkedin/company_success") do
        company = linkedin.company("https://www.linkedin.com/company/shopify")

        # Verify founding info
        assert company.key?(:founded)
        assert_kind_of Integer, company[:founded]

        # Verify slogan
        assert company.key?(:slogan)

        # Verify cover image
        assert company.key?(:cover_image)
      end
    end

    it "fetches company with specialties" do
      VCR.use_cassette("linkedin/company_success") do
        company = linkedin.company("https://www.linkedin.com/company/shopify")

        assert company.key?(:specialties)
        assert_kind_of Array, company[:specialties]
        refute_empty company[:specialties]
      end
    end

    it "fetches company with funding information" do
      VCR.use_cassette("linkedin/company_success") do
        company = linkedin.company("https://www.linkedin.com/company/shopify")

        assert company.key?(:funding)
        assert_kind_of Hash, company[:funding]

        funding = company[:funding]

        assert funding.key?(:number_of_rounds)
        assert funding.key?(:last_round)
        assert funding.key?(:investors)

        if funding[:last_round]
          last_round = funding[:last_round]

          assert last_round.key?(:type)
          assert last_round.key?(:date)
          assert last_round.key?(:amount)
        end

        assert_kind_of Array, funding[:investors]

        if funding[:investors].any?
          investor = funding[:investors].first

          assert investor.key?(:name)
        end
      end
    end

    it "fetches company with similar pages" do
      VCR.use_cassette("linkedin/company_success") do
        company = linkedin.company("https://www.linkedin.com/company/shopify")

        assert company.key?(:similar_pages)
        assert_kind_of Array, company[:similar_pages]

        if company[:similar_pages].any?
          page = company[:similar_pages].first

          assert page.key?(:link)
          assert page.key?(:name)
          assert page.key?(:image)
        end
      end
    end

    it "fetches company with employees" do
      VCR.use_cassette("linkedin/company_success") do
        company = linkedin.company("https://www.linkedin.com/company/shopify")

        assert company.key?(:employees)
        assert_kind_of Array, company[:employees]

        if company[:employees].any?
          employee = company[:employees].first

          assert employee.key?(:name)
          assert employee.key?(:title)
          assert employee.key?(:link)
        end
      end
    end

    it "fetches company with posts" do
      VCR.use_cassette("linkedin/company_success") do
        company = linkedin.company("https://www.linkedin.com/company/shopify")

        assert company.key?(:posts)
        assert_kind_of Array, company[:posts]

        if company[:posts].any?
          post = company[:posts].first

          assert post.key?(:url)
          assert post.key?(:text)
          assert post.key?(:date_published)
        end
      end
    end

    it "raises ArgumentError when url is nil" do
      error = assert_raises(ArgumentError) do
        linkedin.company(nil)
      end
      assert_match(/url is required/, error.message)
    end

    it "raises ArgumentError when url is empty" do
      error = assert_raises(ArgumentError) do
        linkedin.company("")
      end
      assert_match(/url is required/, error.message)
    end

    it "raises NotFoundError for non-existent company" do
      VCR.use_cassette("linkedin/company_not_found") do
        assert_raises(ScrapeCreators::NotFoundError) do
          linkedin.company("https://www.linkedin.com/company/thiscompanydoesnotexist123456789xyz")
        end
      end
    end

    it "raises UnauthorizedError for invalid API key" do
      VCR.use_cassette("linkedin/company_unauthorized") do
        invalid_client = ScrapeCreators::Client.new(api_key: "invalid_key")

        error = assert_raises(ScrapeCreators::UnauthorizedError) do
          invalid_client.linkedin.company("https://www.linkedin.com/company/shopify")
        end

        assert_match(/invalid|unauthorized|api.?key/i, error.message)
      end
    end
  end
end
