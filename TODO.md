# ScrapeCreators API Implementation TODO

This document tracks the implementation status of all ScrapeCreators API endpoints across all platforms.

**Legend:**
- ✅ Completed
- 🚧 In Progress
- ⏳ Not Started

---

## TikTok

### Core Endpoints
- [✅] GET Profile (`/v1/tiktok/profile`)
- [✅] GET User's Audience Demographics (`/v1/tiktok/user/audience`)
- [✅] GET Profile Videos (`/v3/tiktok/profile/videos`)
- [✅] GET Profile Videos - Auto Pagination (`/v3/tiktok/profile-videos`)
- [✅] GET Video Info (`/v2/tiktok/video`)
- [✅] GET Transcript (`/v1/tiktok/video/transcript`)
- [✅] GET TikTok Live (`/v1/tiktok/user/live`)
- [✅] GET Comments (`/v1/tiktok/video/comments`)
- [✅] GET Following (`/v1/tiktok/user/following`)
- [✅] GET Followers (`/v1/tiktok/user/followers`)

### Search Endpoints
- [✅] GET Search Users (`/v1/tiktok/search/users`)
- [✅] GET Search by Hashtag (`/v1/tiktok/search/hashtag`)
- [✅] GET Search by Keyword (`/v1/tiktok/search/keyword`)
- [✅] GET Top Search (`/v1/tiktok/search/top`)

### Songs & Discovery
- [✅] GET Get popular songs (`/v1/tiktok/songs/popular`)
- [✅] GET Get Song Details (`/v1/tiktok/song`)
- [✅] GET TikToks using Song (`/v1/tiktok/song/videos`)
- [✅] GET Trending Feed (`/v1/tiktok/get-trending-feed`)

---

## TikTok Shop

- [✅] GET Shop Search (`/v1/tiktok/shop/search`)
- [✅] GET Shop Products (`/v1/tiktok/shop/products`)
- [✅] GET Product Details (`/v1/tiktok/product`)

---

## Instagram

- [✅] GET Profile (`/v1/instagram/profile`)
- [✅] GET Basic Profile (`/v1/instagram/basic-profile`)
- [✅] GET Posts (`/v2/instagram/user/posts`)
- [✅] GET Post/Reel Info (`/v1/instagram/post`)
- [✅] GET Transcript (`/v2/instagram/media/transcript`)
- [✅] GET Search Reels (`/v1/instagram/reels/search`)
- [✅] GET Comments - Auto Pagination (`/v1/instagram/post/comments`)
- [✅] GET Reels (`/v1/instagram/user/reels`)
- [✅] GET Reels - Auto Pagination (`/v1/instagram/user/reels/simple`)
- [✅] GET Story Highlights (`/v1/instagram/user/highlights`)
- [✅] GET Highlights Details (`/v1/instagram/user/highlight/detail`)
- [✅] GET Reels using Song (`/v1/instagram/song/reels`)
- [✅] GET Embed HTML (`/v1/instagram/user/embed`)

---

## YouTube

- [✅] GET Channel Details (`/v1/youtube/channel`)
- [✅] GET Channel Videos (`/v1/youtube/channel-videos`)
- [✅] GET Channel Shorts (`/v1/youtube/channel/shorts`)
- [✅] GET Channel Shorts - Auto Pagination (`/v1/youtube/channel/shorts/simple`)
- [✅] GET Video/Short Details (`/v1/youtube/video`)
- [✅] GET Transcript (`/v1/youtube/video/transcript`)
- [✅] GET Search (`/v1/youtube/search`)
- [✅] GET Search by Hashtag (`/v1/youtube/search/hashtag`)
- [✅] GET Comments (`/v1/youtube/video/comments`)
- [✅] GET Trending Shorts (`/v1/youtube/shorts/trending`)
- [✅] GET Playlist (`/v1/youtube/playlist`)
- [✅] GET Community Post Details (`/v1/youtube/community-post`)

---

## LinkedIn

- [✅] GET Person's Profile (`/v1/linkedin/profile`)
- [✅] GET Company Page (`/v1/linkedin/company`)
- [✅] GET Post (`/v1/linkedin/post`)

---

## Facebook

- [✅] GET Profile (`/v1/facebook/profile`)
- [✅] GET Profile Posts (`/v1/facebook/profile/posts`)
- [✅] GET Facebook Group Posts (`/v1/facebook/group/posts`)
- [✅] GET Post (`/v1/facebook/post`)
- [✅] GET Transcript (`/v1/facebook/post/transcript`)
- [✅] GET Comments (`/v1/facebook/post/comments`)

---

## Facebook Ad Library

- [✅] GET Ad Details (`/v1/facebook/adLibrary/ad`)
- [✅] GET Search (`/v1/facebook/adLibrary/search/ads`)
- [✅] GET Company Ads (`/v1/facebook/adLibrary/company/ads`)
- [✅] GET Search for Companies (`/v1/facebook/adLibrary/search/companies`)

---

## Google Ad Library

- [✅] GET Company Ads (`/v1/google/company/ads`)
- [✅] GET Ad Details (`/v1/google/ad`)
- [✅] GET Advertiser Search (`/v1/google/adLibrary/advertisers/search`)

---

## LinkedIn Ad Library

- [✅] GET Search Ads (`/v1/linkedin/ads/search`)
- [✅] GET Ad Details (`/v1/linkedin/ad`)

---

## Twitter

- [✅] GET Profile (`/v1/twitter/profile`)
- [✅] GET User Tweets (`/v1/twitter/user-tweets`)
- [✅] GET Tweet Details (`/v1/twitter/tweet`)
- [✅] GET Transcript (`/v1/twitter/tweet/transcript`)
- [✅] GET Community (`/v1/twitter/community`)
- [✅] GET Community Tweets (`/v1/twitter/community/tweets`)

---

## Reddit

- [✅] GET Subreddit Posts (`/v1/reddit/subreddit`)
- [✅] GET Post Comments (`/v1/reddit/post/comments`)
- [✅] GET Simple Comments (`/v1/reddit/post/comments/simple`)
- [✅] GET Search (`/v1/reddit/search`)
- [✅] GET Search Ads (`/v1/reddit/ads/search`)
- [✅] GET Get Ad (`/v1/reddit/ad`)

---

## Truth Social

- [✅] GET Profile (`/v1/truthsocial/profile`)
- [✅] GET User Posts (`/v1/truthsocial/user/posts`)
- [✅] GET Post (`/v1/truthsocial/post`)

---

## Threads

- [✅] GET Profile (`/v1/threads/profile`)
- [✅] GET Posts (`/v1/threads/user/posts`)
- [✅] GET Post (`/v1/threads/post`)
- [✅] GET Search by Keyword (`/v1/threads/search`)
- [✅] GET Search Users (`/v1/threads/search/users`)

---

## Bluesky

- [✅] GET Profile (`/bluesky/profile`)
- [✅] GET Posts (`/bluesky/user/posts`)
- [✅] GET Post (`/bluesky/post`)

---

## Pinterest

- [✅] GET Search (`/v1/pinterest/search`)
- [✅] GET Pin (`/v1/pinterest/pin`)
- [✅] GET User Boards (`/v1/pinterest/user/boards`)
- [✅] GET Board (`/v1/pinterest/board`)

---

## Google

- [✅] GET Search (`/v1/google/search`)

---

## Twitch

- [✅] GET Profile (`/v1/twitch/profile`)
- [✅] GET Clip (`/v1/twitch/clip`)

---

## Kick

- [✅] GET Clip (`/v1/kick/clip`)

---

## Snapchat

- [✅] GET User Profile (`/v1/snapchat/profile`)

---

## Linktree

- [✅] GET Linktree page (`/v1/linktree`)

---

## Komi

- [✅] GET Komi page (`/v1/komi`)

---

## Pillar

- [✅] GET Pillar page (`/v1/pillar`)

---

## Linkbio

- [✅] GET Linkbio page (`/v1/linkbio`)

---

## Amazon Shop

- [✅] GET Amazon Shop page (`/v1/amazon/shop`)

---

## Age and Gender

- [✅] GET Get Age and Gender (`/v1/detect-age-gender`)

---

## Scrape Creators

- [✅] GET Get credit balance (`/v1/credit-balance`)

---

## Implementation Progress Summary

**Total Endpoints:** 103
**Completed:** 103
**Remaining:** 0

### Platform Completion Status
- TikTok: 18/18 endpoints (100%)
- TikTok Shop: 3/3 endpoints (100%)
- Instagram: 13/13 endpoints (100%)
- YouTube: 12/12 endpoints (100%)
- LinkedIn: 3/3 endpoints (100%)
- Facebook: 6/6 endpoints (100%)
- Facebook Ad Library: 4/4 endpoints (100%)
- Google Ad Library: 3/3 endpoints (100%)
- LinkedIn Ad Library: 2/2 endpoints (100%)
- Twitter: 6/6 endpoints (100%)
- Reddit: 6/6 endpoints (100%)
- Truth Social: 3/3 endpoints (100%)
- Threads: 5/5 endpoints (100%)
- Bluesky: 3/3 endpoints (100%)
- Pinterest: 4/4 endpoints (100%)
- Google: 1/1 endpoints (100%)
- Twitch: 2/2 endpoints (100%)
- Kick: 1/1 endpoints (100%)
- Snapchat: 1/1 endpoints (100%)
- Linktree: 1/1 endpoints (100%)
- Komi: 1/1 endpoints (100%)
- Pillar: 1/1 endpoints (100%)
- Linkbio: 1/1 endpoints (100%)
- Amazon Shop: 1/1 endpoints (100%)
- Age and Gender: 1/1 endpoints (100%)
- Scrape Creators: 1/1 endpoints (100%)

---

## Notes

- Each endpoint requires implementation in a resource class (`lib/scrape_creators/resources/`)
- Comprehensive tests with VCR cassettes required for each endpoint
- YARD documentation must be added for all public methods
- Follow existing TikTok implementation pattern for consistency
