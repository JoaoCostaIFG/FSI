#!/bin/sh

N="${1:-20}"

curl --globoff \
  --data-urlencode 'q=+"version control" tools -svn' \
  --data-urlencode "q.op=AND" \
  --data-urlencode "indent=true" \
  --data-urlencode "rows=$N" \
  --data-urlencode "defType=edismax" \
  --data-urlencode "qf=story_type^10 story_title^3 story_text^3 url^2 url_text comments.comment_text newssite_filter^10" \
  "http://localhost:8983/solr/hackersearch/select"
