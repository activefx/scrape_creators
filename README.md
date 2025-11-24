# ScrapeCreators

A Ruby client library for the [ScrapeCreators API](https://scrapecreators.com), providing social media data extraction capabilities across 25+ platforms including TikTok, Instagram, YouTube, Twitter, LinkedIn, and more.

## Quick Start

```ruby
require "scrape_creators"

# Configure with your API key
ScrapeCreators.configure do |config|
  config.api_key = "your_api_key"
end

# Create a client
client = ScrapeCreators::Client.new

# Get a TikTok profile
profile = client.tiktok.profile("stoolpresidente")
puts profile[:user][:nickname]        # => "Dave Portnoy"
puts profile[:stats][:follower_count] # => 4100000

# Get an Instagram profile
profile = client.instagram.profile("adrianhorning")
puts profile[:data][:user][:full_name] # => "Adrian Horning"

# Get a YouTube channel
channel = client.youtube.channel(handle: "mrbeast")
puts channel[:title]            # => "MrBeast"
puts channel[:subscriber_count] # => 358000000

# Check your credit balance
balance = client.account.credit_balance
puts "Credits remaining: #{balance[:credit_count]}"
```

## Basic Examples

### TikTok

```ruby
# Get profile information
profile = client.tiktok.profile("username")

# Get user's videos with auto-pagination
videos = client.tiktok.profile_videos_paginated(handle: "username", amount: 50)

# Get video details with transcript
video = client.tiktok.video("https://www.tiktok.com/@user/video/123", get_transcript: true)

# Search for users
results = client.tiktok.search_users("taylor swift")

# Search videos by hashtag
results = client.tiktok.search_hashtag("fyp")

# Get trending feed
trending = client.tiktok.trending_feed("US")

# Get video comments with pagination
comments = client.tiktok.video_comments("https://www.tiktok.com/@user/video/123")
next_page = client.tiktok.video_comments("https://...", cursor: comments[:cursor])
```

### Instagram

```ruby
# Get profile information
profile = client.instagram.profile("username")

# Get user's posts with pagination
posts = client.instagram.posts("username")
next_page = client.instagram.posts("username", next_max_id: posts[:next_max_id])

# Get post/reel details
post = client.instagram.post("https://www.instagram.com/p/ABC123/")

# Get video transcript (AI-powered)
transcript = client.instagram.transcript("https://www.instagram.com/reel/XYZ789/")

# Get user's reels
reels = client.instagram.reels(handle: "username")

# Search reels by keyword
results = client.instagram.search_reels("fitness", amount: 20)

# Get story highlights
highlights = client.instagram.highlights(handle: "username")
```

### YouTube

```ruby
# Get channel details
channel = client.youtube.channel(handle: "mrbeast")

# Get channel videos
videos = client.youtube.channel_videos(handle: "mrbeast", sort: "popular")

# Get video details with transcript
video = client.youtube.video("https://www.youtube.com/watch?v=ABC123", get_transcript: true)

# Search videos
results = client.youtube.search("cooking recipes")

# Get video comments
comments = client.youtube.video_comments("https://www.youtube.com/watch?v=ABC123")

# Get trending shorts
shorts = client.youtube.trending_shorts
```

### Twitter

```ruby
# Get profile
profile = client.twitter.profile("username")

# Get user's tweets
tweets = client.twitter.user_tweets("username")

# Get tweet details
tweet = client.twitter.tweet("https://twitter.com/user/status/123")

# Get video transcript
transcript = client.twitter.tweet_transcript("https://twitter.com/user/status/123")
```

### LinkedIn

```ruby
# Get person's profile
profile = client.linkedin.profile("https://www.linkedin.com/in/username/")

# Get company page
company = client.linkedin.company("https://www.linkedin.com/company/example/")

# Get post details
post = client.linkedin.post("https://www.linkedin.com/posts/...")
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "scrape_creators"
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install scrape_creators
```

## Configuration

### Global Configuration

```ruby
ScrapeCreators.configure do |config|
  config.api_key = "your_api_key"
  config.base_url = "https://api.scrapecreators.com"  # optional
  config.timeout = 30                                  # optional, in seconds
  config.max_retries = 3                               # optional
  config.debug = false                                 # optional, enables logging
end

client = ScrapeCreators::Client.new
```

### Per-Instance Configuration

```ruby
client = ScrapeCreators::Client.new(
  api_key: "your_api_key",
  timeout: 60,
  debug: true
)
```

## Resources

### Social Media Platforms

| Resource | Access | Description |
|----------|--------|-------------|
| `tiktok` | `client.tiktok` | Profiles, videos, comments, search, trending, songs, followers/following |
| `tiktok_shop` | `client.tiktok_shop` | Shop search, products, product details |
| `instagram` | `client.instagram` | Profiles, posts, reels, comments, highlights, search, transcripts |
| `youtube` | `client.youtube` | Channels, videos, shorts, comments, search, transcripts, playlists |
| `twitter` | `client.twitter` | Profiles, tweets, transcripts, communities |
| `linkedin` | `client.linkedin` | Person profiles, company pages, posts |
| `facebook` | `client.facebook` | Profiles, posts, group posts, comments, transcripts |
| `threads` | `client.threads` | Profiles, posts, search |
| `bluesky` | `client.bluesky` | Profiles, posts |
| `reddit` | `client.reddit` | Subreddits, post comments, search |
| `truth_social` | `client.truth_social` | Profiles, posts |
| `pinterest` | `client.pinterest` | Search, pins, boards |
| `twitch` | `client.twitch` | Profiles, clips |
| `kick` | `client.kick` | Clips |
| `snapchat` | `client.snapchat` | Profiles |

### Ad Libraries

| Resource | Access | Description |
|----------|--------|-------------|
| `facebook_ad_library` | `client.facebook_ad_library` | Ad details, search ads, company ads |
| `google_ad_library` | `client.google_ad_library` | Company ads, ad details, advertiser search |
| `linkedin_ad_library` | `client.linkedin_ad_library` | Search ads, ad details |

### Link-in-Bio Platforms

| Resource | Access | Description |
|----------|--------|-------------|
| `linktree` | `client.linktree` | Linktree pages |
| `komi` | `client.komi` | Komi pages |
| `pillar` | `client.pillar` | Pillar pages |
| `linkbio` | `client.linkbio` | Linkbio pages |

### Other Services

| Resource | Access | Description |
|----------|--------|-------------|
| `google` | `client.google` | Google search |
| `amazon_shop` | `client.amazon_shop` | Amazon influencer storefronts |
| `age_gender` | `client.age_gender` | Detect age and gender from images |
| `account` | `client.account` | Credit balance |

## Resource Details

### TikTok (`client.tiktok`)

- `profile(handle)` - Get user profile
- `audience(handle)` - Get audience demographics (26 credits)
- `profile_videos(handle, ...)` - Get videos with manual pagination
- `profile_videos_paginated(handle:, ...)` - Get videos with auto-pagination
- `video(url, ...)` - Get video details
- `video_transcript(url, ...)` - Get video transcript
- `user_live(handle)` - Check if user is live streaming
- `video_comments(url, ...)` - Get video comments
- `user_following(handle, ...)` - Get following list
- `user_followers(handle:, ...)` - Get followers list
- `search_users(query, ...)` - Search for users
- `search_keyword(query, ...)` - Search videos by keyword
- `search_hashtag(hashtag, ...)` - Search videos by hashtag
- `search_top(query, ...)` - Search top results (videos + carousels)
- `popular_songs(...)` - Get popular songs
- `song(clip_id)` - Get song details
- `song_videos(clip_id, ...)` - Get videos using a song
- `trending_feed(region, ...)` - Get trending feed
- `shop_search(query, ...)` - Search TikTok Shop products
- `shop_product(url, ...)` - Get product details
- `shop_products(url, ...)` - Get all products from a shop

### Instagram (`client.instagram`)

- `profile(handle, ...)` - Get user profile
- `basic_profile(user_id)` - Get basic profile by user ID (free)
- `posts(handle, ...)` - Get user posts
- `post(url, ...)` - Get post/reel details
- `transcript(url)` - Get video transcript (AI-powered)
- `search_reels(query, ...)` - Search reels by keyword
- `reels(user_id:, handle:, ...)` - Get user reels with pagination
- `reels_simple(user_id:, handle:, ...)` - Get user reels with auto-pagination
- `comments(url, ...)` - Get post comments
- `highlights(user_id:, handle:)` - Get story highlights
- `highlight_detail(id)` - Get highlight details
- `song_reels(audio_id, ...)` - Get reels using a song
- `embed(handle)` - Get embed HTML

### YouTube (`client.youtube`)

- `channel(channel_id:, handle:, url:)` - Get channel details
- `channel_videos(channel_id:, handle:, ...)` - Get channel videos
- `channel_shorts(channel_id:, handle:, ...)` - Get channel shorts
- `channel_shorts_simple(channel_id:, handle:, ...)` - Get shorts with auto-pagination
- `video(url, ...)` - Get video details
- `video_transcript(url, ...)` - Get video transcript
- `search(query, ...)` - Search videos
- `search_hashtag(hashtag, ...)` - Search by hashtag
- `video_comments(url, ...)` - Get video comments
- `trending_shorts(...)` - Get trending shorts
- `playlist(url, ...)` - Get playlist videos
- `community_post(url)` - Get community post details

### Twitter (`client.twitter`)

- `profile(handle)` - Get user profile
- `user_tweets(handle, ...)` - Get user tweets
- `tweet(url)` - Get tweet details
- `tweet_transcript(url)` - Get video transcript
- `community(community_id)` - Get community info
- `community_tweets(community_id, ...)` - Get community tweets

### LinkedIn (`client.linkedin`)

- `profile(url)` - Get person's profile
- `company(url)` - Get company page
- `post(url)` - Get post details

### Facebook (`client.facebook`)

- `profile(url)` - Get profile
- `profile_posts(url, ...)` - Get profile posts
- `group_posts(url, ...)` - Get group posts
- `post(url)` - Get post details
- `post_transcript(url)` - Get video transcript
- `post_comments(url, ...)` - Get post comments

### Threads (`client.threads`)

- `profile(handle)` - Get user profile
- `user_posts(handle, ...)` - Get user posts
- `post(url)` - Get post details
- `search(query, ...)` - Search by keyword
- `search_users(query, ...)` - Search users

### Other Resources

See the [API documentation](https://docs.scrapecreators.com/introduction) for complete details on all endpoints.

## Error Handling

```ruby
begin
  profile = client.tiktok.profile("nonexistent_user")
rescue ScrapeCreators::NotFoundError => e
  puts "User not found: #{e.message}"
rescue ScrapeCreators::UnauthorizedError => e
  puts "Invalid API key: #{e.message}"
rescue ScrapeCreators::PaymentRequiredError => e
  puts "Insufficient credits: #{e.message}"
rescue ScrapeCreators::RateLimitError => e
  puts "Rate limited. Retry after: #{e.retry_after} seconds"
rescue ScrapeCreators::BadRequestError => e
  puts "Invalid request: #{e.message}"
rescue ScrapeCreators::ServerError => e
  puts "Server error: #{e.message}"
rescue ScrapeCreators::Error => e
  puts "API error: #{e.message}"
end
```

## Pagination

Most list endpoints support pagination:

```ruby
# Manual cursor-based pagination
page1 = client.tiktok.profile_videos("username")
page2 = client.tiktok.profile_videos("username", max_cursor: page1[:max_cursor]) if page1[:has_more]

# Auto-pagination (fetches specified amount automatically)
videos = client.tiktok.profile_videos_paginated(handle: "username", amount: 100)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

```bash
# Run tests
rake test

# Run console for experimentation
bin/console

# Generate documentation
rake yard
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/activefx/scrape_creators.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
