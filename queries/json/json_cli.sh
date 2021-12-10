#!/bin/sh

N="${1:-20}"

curl --globoff --data-urlencode \
  "indent=true" \
  --data-urlencode "q.op=AND" \
  --data-urlencode 'q=json tool "command line"' \
  --data-urlencode "rows=$N" \
  "http://localhost:8983/solr/hackersearch/select"
