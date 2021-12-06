#!/bin/sh

curl --globoff "http://localhost:8983/solr/hackersearch/select?q=(url_url:command+line+json)^3+||+(story_title:command+line+json)^3+||+(story_title:command+line+json)^2+||+(url_text:command+line+json)^2+||+(comment_text:command+line+json)&fl=story_title&fq=story_score:[20+TO+*]"
