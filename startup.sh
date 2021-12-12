#!/bin/bash

# start Solr in background mode so we can use the API to upload the schema
solr start

solr create -c hackersearch

# synonyms and stuff
cp /data/mysynonyms.txt /var/solr/data/hackersearch/mysynonyms.txt
cp /data/newssites.txt /var/solr/data/hackersearch/newssites.txt
cp /data/newsword.txt /var/solr/data/hackersearch/newsword.txt

# turn of automatic field creation
#bin/solr config -c hackersearch -p 8983 -action set-user-property -property update.autoCreateFields -value false

# schema definition via API
curl -X POST -H 'Content-type:application/json' \
    --data-binary @/data/hackersearch_schema.json \
    http://localhost:8983/solr/hackersearch/schema

# request handler defaults
curl -X POST -H 'Content-type:application/json' \
  --data-binary '{
    "update-requesthandler": {
      "name": "/select",
      "class": "solr.SearchHandler",
      "defaults": {
        "wt": "json", 
        "indent": true,
        "df": "search"
      },
    }
  }' \
  http://localhost:8983/solr/hackersearch/config

# populate collection
bin/post -c hackersearch /data/hackersearch.json

# restart in foreground mode so we can access the interface
solr restart -f
