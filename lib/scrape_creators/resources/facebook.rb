# frozen_string_literal: true

module ScrapeCreators
  module Resources
    # Facebook API resource
    #
    # Provides methods to interact with Facebook endpoints for scraping public profile data,
    # business information, and more.
    #
    # @see https://docs.scrapecreators.com/v1/facebook Facebook API Documentation
    class Facebook < Resource
      # Get public Facebook profile information
      #
      # Scrapes a public Facebook profile including business information, contact details,
      # photos, ratings, and social metrics.
      #
      # @param url [String] Facebook profile URL
      # @param get_business_hours [Boolean, nil] Whether to include business hours in the response
      # @return [Hash] Profile data including business info, photos, and social metrics
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Facebook profile
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   profile = client.facebook.profile("https://www.facebook.com/copperkettleyqr/")
      #   puts profile[:name]           # => "The Copper Kettle Restaurant"
      #   puts profile[:follower_count] # => 2900
      #
      # @example Get a Facebook profile with business hours
      #   profile = client.facebook.profile("https://www.facebook.com/copperkettleyqr/", get_business_hours: true)
      #   puts profile[:business_hours] # => [{ monday: { open: "11:00", close: "00:00", ... } }, ...]
      #
      # @example Response structure
      #   {
      #     success: true,
      #     credits_remaining: 9946894,
      #     ad_library: {
      #       ad_status: "This Page is currently running ads.",
      #       page_id: "851606664870954"
      #     },
      #     creation_date: "October 29, 2014",
      #     business_hours: [
      #       {
      #         monday: {
      #           open: "11:00",
      #           close: "00:00",
      #           full_text: "11:00 - 00:00"
      #         }
      #       }
      #     ],
      #     id: "100064027242849",
      #     name: "The Copper Kettle Restaurant",
      #     url: "https://www.facebook.com/copperkettleyqr/",
      #     gender: "NEUTER",
      #     cover_photo: {
      #       focus: { x: 0.5, y: 0.48327464788732 },
      #       photo: {
      #         id: "436705571807014",
      #         image: {
      #           uri: "https://...",
      #           width: 960,
      #           height: 641
      #         },
      #         url: "https://www.facebook.com/photo/?fbid=..."
      #       }
      #     },
      #     is_business_page_active: false,
      #     profile_photo: {
      #       url: "https://www.facebook.com/photo/?fbid=...",
      #       viewer_image: { height: 320, width: 320 },
      #       id: "436705568473681"
      #     },
      #     profile_pic_large: "https://...",
      #     profile_pic_medium: "https://...",
      #     profile_pic_small: "https://...",
      #     page_intro: "Longstanding local restaurant. Mediterranean specialties...",
      #     category: "Pizza place",
      #     address: "1953 Scarth Street, Regina, SK, Canada, Saskatchewan",
      #     email: "copperkettle.events@gmail.com",
      #     links: ["https://www.instagram.com/copperkettleyqr"],
      #     phone: "+1 306-525-3545",
      #     website: "http://www.thecopperkettle.online/",
      #     services: "Outdoor seating",
      #     price_range: "££",
      #     rating: "94% recommend (205 reviews)",
      #     rating_count: nil,
      #     like_count: 2660,
      #     follower_count: 2900
      #   }
      def profile(url, get_business_hours: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:get_business_hours] = get_business_hours unless get_business_hours.nil?

        get("/v1/facebook/profile", params)
      end

      # Get posts from a public Facebook profile
      #
      # Retrieves posts from a public Facebook profile including engagement metrics,
      # content, media details, and timestamps. Returns only posts visible from an
      # incognito browser session. Only returns 3 posts at a time.
      #
      # @param url [String, nil] Facebook profile URL (either url or page_id is required)
      # @param page_id [String, nil] Facebook profile page ID (faster than url lookup)
      # @param cursor [String, nil] Pagination cursor to get the next page of posts
      # @return [Hash] Posts data including posts array and pagination cursor
      # @raise [ArgumentError] If both url and page_id are nil or empty
      # @raise [NotFoundError] If the profile is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get posts using profile URL
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   posts = client.facebook.profile_posts(url: "https://www.facebook.com/pacemorby/")
      #   puts posts[:posts].first[:text]
      #
      # @example Get posts using page ID (faster)
      #   posts = client.facebook.profile_posts(page_id: "100063669491743")
      #   posts[:posts].each { |post| puts post[:text] }
      #
      # @example Paginate through posts
      #   first_page = client.facebook.profile_posts(url: "https://www.facebook.com/pacemorby/")
      #   if first_page[:cursor]
      #     next_page = client.facebook.profile_posts(
      #       url: "https://www.facebook.com/pacemorby/",
      #       cursor: first_page[:cursor]
      #     )
      #   end
      #
      # @example Response structure
      #   {
      #     success: true,
      #     posts: [
      #       {
      #         id: "1204545088344463",
      #         text: "Post content here...",
      #         url: "https://www.facebook.com/reel/486651220706068/",
      #         permalink: "https://www.facebook.com/reel/486651220706068/",
      #         author: {
      #           __typename: "User",
      #           name: "Pace Morby",
      #           short_name: "Pace Morby",
      #           id: "100063669491743"
      #         },
      #         video_details: {
      #           sd_url: "https://...",
      #           hd_url: "https://...",
      #           thumbnail_url: "https://..."
      #         },
      #         reaction_count: 133,
      #         comment_count: 12,
      #         video_view_count: nil,
      #         publish_time: 1734553170,
      #         top_comments: [
      #           {
      #             id: "Y29...",
      #             text: "How can I sign up?",
      #             publish_time: 1734569761,
      #             author: {
      #               id: "pfbid...",
      #               name: "User Name",
      #               gender: "MALE",
      #               url: nil
      #             }
      #           }
      #         ]
      #       }
      #     ],
      #     cursor: "Cg8Ob3JnYW5pY19jdXJzb3IJ..."
      #   }
      def profile_posts(url: nil, page_id: nil, cursor: nil)
        if (url.nil? || url.to_s.empty?) && (page_id.nil? || page_id.to_s.empty?)
          raise ArgumentError, "url or page_id is required"
        end

        params = {}
        params[:url] = url unless url.nil? || url.to_s.empty?
        params[:pageId] = page_id unless page_id.nil? || page_id.to_s.empty?
        params[:cursor] = cursor unless cursor.nil?

        get("/v1/facebook/profile/posts", params)
      end

      # Get posts from a public Facebook group
      #
      # Retrieves posts from a public Facebook group including engagement metrics,
      # content, media details, and timestamps. Only returns 3 posts at a time due
      # to Facebook API limitations.
      #
      # @param url [String, nil] Facebook group URL (either url or group_id is required)
      # @param group_id [String, nil] Facebook group ID (faster than url lookup)
      # @param sort_by [String, nil] How to sort the posts
      #   (TOP_POSTS, RECENT_ACTIVITY, CHRONOLOGICAL, CHRONOLOGICAL_LISTINGS)
      # @param cursor [String, nil] Pagination cursor to get the next page of posts
      # @return [Hash] Posts data including posts array and pagination cursor
      # @raise [ArgumentError] If both url and group_id are nil or empty
      # @raise [NotFoundError] If the group is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get group posts using URL
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   posts = client.facebook.group_posts(url: "https://www.facebook.com/groups/742354120555345")
      #   puts posts[:posts].first[:text]
      #
      # @example Get group posts using group ID (faster)
      #   posts = client.facebook.group_posts(group_id: "742354120555345")
      #   posts[:posts].each { |post| puts post[:text] }
      #
      # @example Get top posts from a group
      #   posts = client.facebook.group_posts(
      #     url: "https://www.facebook.com/groups/742354120555345",
      #     sort_by: "TOP_POSTS"
      #   )
      #
      # @example Paginate through posts
      #   first_page = client.facebook.group_posts(url: "https://www.facebook.com/groups/742354120555345")
      #   if first_page[:cursor]
      #     next_page = client.facebook.group_posts(
      #       url: "https://www.facebook.com/groups/742354120555345",
      #       cursor: first_page[:cursor]
      #     )
      #   end
      #
      # @example Response structure
      #   {
      #     success: true,
      #     credits_remaining: 48026,
      #     post_id: "25118307061088489",
      #     like_count: 2095,
      #     comment_count: 48,
      #     share_count: 133,
      #     view_count: 133000,
      #     description: "Air Fryer Chocolate Cake...",
      #     feedback_id: "ZmVlZGJhY2s6MjUxMDIxMDY3OTkzNzUxODI=",
      #     url: "https://www.facebook.com/reel/1535656380759655",
      #     image_url: nil,
      #     video: {
      #       id: "1535656380759655",
      #       sd_url: "https://...",
      #       hd_url: "https://...",
      #       height: 1920,
      #       width: 1080,
      #       length_in_second: 23.36,
      #       thumbnail: "https://...",
      #       captions_url: "https://..."
      #     },
      #     author: {
      #       id: "100000076236457",
      #       name: "Matt West",
      #       is_verified: true,
      #       url: "https://www.facebook.com/matt.west.184",
      #       image: "https://..."
      #     },
      #     music: {
      #       id: "1506592770696336",
      #       type: "CUSTOM_AUDIO",
      #       track_title: "Matt West · Original audio",
      #       music_album_art: "https://..."
      #     }
      #   }
      def group_posts(url: nil, group_id: nil, sort_by: nil, cursor: nil)
        if (url.nil? || url.to_s.empty?) && (group_id.nil? || group_id.to_s.empty?)
          raise ArgumentError, "url or group_id is required"
        end

        params = {}
        params[:url] = url unless url.nil? || url.to_s.empty?
        params[:groupId] = group_id unless group_id.nil? || group_id.to_s.empty?
        params[:sort_by] = sort_by unless sort_by.nil?
        params[:cursor] = cursor unless cursor.nil?

        get("/v1/facebook/group/posts", params)
      end

      # Get detailed information about a specific Facebook post
      #
      # Retrieves detailed information about a public Facebook post including
      # engagement metrics, content, and optional comments and transcript.
      #
      # @param url [String] Facebook post URL
      # @param get_comments [Boolean, nil] Whether to include comments in the response
      # @param get_transcript [Boolean, nil] Whether to include video transcript in the response
      # @return [Hash] Post data including content, engagement metrics, and optional comments/transcript
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the post is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Facebook post
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   post = client.facebook.post("https://www.facebook.com/reel/486651220706068/")
      #   puts post[:description]
      #   puts post[:like_count]
      #
      # @example Get a Facebook post with comments
      #   post = client.facebook.post("https://www.facebook.com/reel/486651220706068/", get_comments: true)
      #   puts post[:comments]
      #
      # @example Get a Facebook post with transcript
      #   post = client.facebook.post("https://www.facebook.com/reel/486651220706068/", get_transcript: true)
      #   puts post[:transcript]
      def post(url, get_comments: nil, get_transcript: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:get_comments] = get_comments unless get_comments.nil?
        params[:get_transcript] = get_transcript unless get_transcript.nil?

        get("/v1/facebook/post", params)
      end

      # Get the transcript of a Facebook post
      #
      # Retrieves the transcript of a Facebook video post or reel. This is useful
      # for extracting spoken content from video posts.
      #
      # @param url [String] Facebook post URL (can be a post or reel)
      # @return [Hash] Transcript data including the transcript text
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the post is not found or has no transcript
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get a Facebook post transcript
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.facebook.transcript("https://www.facebook.com/reel/486651220706068/")
      #   puts result[:transcript] # => "Hello, world!"
      #
      # @example Response structure
      #   {
      #     success: true,
      #     transcript: "Hello, world!"
      #   }
      def transcript(url)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        get("/v1/facebook/post/transcript", url: url)
      end

      # Get comments from a Facebook post or reel
      #
      # Retrieves comments from a public Facebook post or reel including author
      # information, engagement metrics, and pagination support.
      #
      # @param url [String] Facebook post URL (or reel URL)
      # @param cursor [String, nil] Pagination cursor from previous response to get more comments
      # @return [Hash] Comments data including comments array, cursor, and has_next_page flag
      # @raise [ArgumentError] If the url parameter is nil or empty
      # @raise [BadRequestError] If the url parameter is invalid
      # @raise [NotFoundError] If the post is not found
      # @raise [UnauthorizedError] If the API key is invalid
      # @raise [PaymentRequiredError] If credits are insufficient
      #
      # @example Get comments from a Facebook post
      #   client = ScrapeCreators::Client.new(api_key: "your_api_key")
      #   result = client.facebook.comments("https://www.facebook.com/reel/1206903601483960/")
      #   result[:comments].each { |comment| puts "#{comment[:author][:name]}: #{comment[:text]}" }
      #
      # @example Paginate through comments
      #   first_page = client.facebook.comments("https://www.facebook.com/reel/1206903601483960/")
      #   if first_page[:has_next_page]
      #     next_page = client.facebook.comments(
      #       "https://www.facebook.com/reel/1206903601483960/",
      #       cursor: first_page[:cursor]
      #     )
      #   end
      #
      # @example Response structure
      #   {
      #     success: true,
      #     comments: [
      #       {
      #         id: "Y29tbWVudDoxMjA2OTAzNjAxNDgzOTYwXzc4NzQ2NjY0NzI2NTk4Mw==",
      #         text: "How are you not 300lbs?",
      #         created_at: "2025-09-01T00:38:58.000Z",
      #         reply_count: 16,
      #         reaction_count: 76,
      #         author: {
      #           id: "pfbid0Ay28K5Lc7QpQLD8wZEHrq4ertocvWcZApjZjDoRqfkYQSzSxaPBS7qFt53v95rERl",
      #           name: "George Bergerac",
      #           gender: "MALE",
      #           profile_picture: "https://...",
      #           short_name: "George"
      #         }
      #       }
      #     ],
      #     cursor: "MToxNzU3MTA2NzYyOg....",
      #     has_next_page: true
      #   }
      def comments(url, cursor: nil)
        raise ArgumentError, "url is required" if url.nil? || url.to_s.empty?

        params = { url: url }
        params[:cursor] = cursor unless cursor.nil?

        get("/v1/facebook/post/comments", params)
      end
    end
  end
end
