#!/bin/sh

N="${1:-10}"

# TODO Maybe make sort optional?
curl --globoff \
  --data-urlencode "q=eclipse ide" \
  --data-urlencode "rows=$N" \
  --data-urlencode "sort=score desc" \
  "http://localhost:8983/solr/hackersearch/select"
