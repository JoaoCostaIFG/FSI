#!/bin/sh

N="${1:-20}"

curl --globoff \
  --data-urlencode "q=eclipse" \
  --data-urlencode "rows=$N" \
  "http://localhost:8983/solr/hackersearch/select"
