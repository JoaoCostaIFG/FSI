#!/bin/sh

# create temporary file to hold data
tmp_f="$(mktemp)"

# select alive posts that haven't "failed"
jq -c '[.[] | select(.dead == null and .score >= 5)]' < stories.json > "$tmp_f"
mv "$tmp_f" stories.json
