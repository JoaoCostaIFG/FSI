#!/bin/sh

curl --globoff --data-urlencode \
  "q=eclipse" \
  "http://localhost:8983/solr/hackersearch/select"
