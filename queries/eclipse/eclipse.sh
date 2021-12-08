#!/bin/sh

N="${1:-10}"

# TODO Maybe make sort optional?
curl --globoff \
  --data-urlencode "q=eclipse" \
  --data-urlencode "fl=story_id, story_title, story_text, url_text" \
  --data-urlencode "rows=$N" \
  --data-urlencode "q.op=OR" \
  --data-urlencode "sort=score desc" \
  "http://localhost:8983/solr/hackersearch/select"
