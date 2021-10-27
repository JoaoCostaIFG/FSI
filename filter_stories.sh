#!/bin/sh

# create temporary file to hold data
tmp_f="$(mktemp)"

jq '.[] | select(.dead == null, .dead == false)' < stories.json > "$tmp_f"
mv "$tmp_f" stories.json
