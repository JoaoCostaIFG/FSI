#!/bin/sh
#
# Get the stories of the dataset.
# This data is divided into multiple JSON files that we join into 1
# single JSON array
#

# get dataset
rm -rf "hackernews-post-datasets"
git clone "https://github.com/massanishi/hackernews-post-datasets"

# join json files
cat hackernews-post-datasets/*.json | jq -c -s add >stories.json

# cleanup
rm -rf "hackernews-post-datasets"
