#!/bin/sh

N="${1:-20}"

  #--data-urlencode "qf=story_type^10 story_title^3 story_text^3 url^2 url_text comments.comment_text newssite_filter^10" \
curl --globoff \
  --data-urlencode "q=eclipse" \
  --data-urlencode "rows=$N" \
  --data-urlencode "defType=edismax" \
  "http://localhost:8983/solr/hackersearch/select"
