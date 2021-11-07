# HackerSearch - PRI 21/22

## Usage

Run `make` in the root folder.

### Dependencies
Make sure you have the following dependencies installed before running the project: 

- [jq](https://stedolan.github.io/jq/)
- [pandas](https://pandas.pydata.org/)
- [numpy](https://numpy.org/)
- [html](https://pypi.org/project/html/)
- [sqlalchemy](https://www.sqlalchemy.org/)


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

## Tools for data colection/processing

- [Mozilla's readability.js](https://github.com/mozilla/readability)
- [JSDom](https://github.com/jsdom/jsdom)
- [jq](https://stedolan.github.io/jq/)
- [HackerNews API](https://github.com/HackerNews/API)
- [Curl](https://curl.se/)
