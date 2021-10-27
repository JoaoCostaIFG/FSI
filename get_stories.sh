#!/bin/sh

# get dataset
rm -rf "hackernews-post-datasets"
git clone "https://github.com/massanishi/hackernews-post-datasets"

# join json files
cat hackernews-post-datasets/*.json | jq -s add >stories.json

# cleanup
rm -rf "hackernews-post-datasets"
