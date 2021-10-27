# HackerSearch - PRI 21/22

## Dataset

Taken from a
[repository](https://github.com/massanishi/hackernews-post-datasets) hosted on
github. This dataset contains stories from
[HackerNews](https://news.ycombinator.com/) that have at least 2 comments. This
was a simple attempt to reduce the dataset size to its essence. This dataset
corresponds to 1.5% of total items (239621 posts).

To clarify what we mean by stories, HackerNews' items are divided into
categories: job offers, stories, comments (children of stories or job offers),
polls, poll options (children of polls).

The dataset referenced above only includes stories. We'll complement it using
the [official HackerNews API](https://github.com/HackerNews/API) to get
top-level comments on these posts. This means that we'll only get the direct
comments of the post and the direct children of these comments.
