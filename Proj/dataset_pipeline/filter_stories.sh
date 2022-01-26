#!/bin/sh
#
# filter the stories by following metrics:
# - select alive posts (not dead and not deleted)
# - that haven't "failed" => score higher than 5
#   (which means they could've made it to the front page)
# - that were posted in 2019 (https://time.is/Unix_time_converter)
#   (1546300800 == Jan. 1 2019 UTC)
#   (1577836800 == Jan. 1 2020 UTC)
# 

out_file="stories.json"

# create temporary file to hold data
tmp_f="$(mktemp)"

# filter the stories
jq -c '[.[] | select((.dead == null or .dead == false) and
  (.deleted == null or .deleted == false) and
  .score >= 5 and
  (.time >= 1546300800 and .time < 1577836800))]' <"$out_file" >"$tmp_f"
mv "$tmp_f" "$out_file"
