#!/bin/sh

N="${1:-20}"

curl --globoff \
  --data-urlencode "q=version control tools" \
  --data-urlencode "q.op=AND" \
  --data-urlencode "indent=true" \
  --data-urlencode "rows=$N" \
  "http://localhost:8983/solr/hackersearch/select"
