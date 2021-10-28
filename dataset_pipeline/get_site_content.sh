#!/bin/sh

out_file="html_content.json"
rm -f "$out_file"

i=0

jq -c '.[] | select(.url != null)' <stories.json |
  while read -r item; do
    echo "$i"
    i=$((i + 1))

    id="$(echo "$item" | jq -r '.id')"
    url="$(echo "$item" | jq -r '.url')"
    html_content="$(readability "$url" 2>/dev/null)"

    printf "{\"id\": %s, \"html_content\": \"%s\"}" "$id" "$html_content" >> "$out_file"
  done

