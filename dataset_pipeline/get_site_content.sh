#!/bin/bash

out_file="html_content.json"
rm -f "$out_file"

i=0

jq -c '.[] | select(.url != null)' <stories.json |
  while read -r item; do
    id="$(echo "$item" | jq -r '.id')"
    url="$(echo "$item" | jq -r '.url')"

    echo "$i - $id - $url"
    i=$((i + 1))

    html_content="$(readability "$url" | sed 's/\"/\\\"/g' |
      tr '\n' ' ' | tr '\t' ' ' | sed 's/[ ]\+/ /g')"

    printf '{"id": %s, "html_content": "%s"}\n' "$id" "$html_content" >> "$out_file"
  done

