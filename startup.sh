#!/bin/bash

#precreate-core hackersearch

# Start Solr in background mode so we can use the API to upload the schema
solr start

solr create -c hackersearch

# Schema definition via API
curl -X POST -H 'Content-type:application/json' \
    --data-binary @/data/hackersearch_schema.json \
    http://localhost:8983/solr/hackersearch/schema

# Populate collection
bin/post -c hackersearch /data/hackersearch.json

# Restart in foreground mode so we can access the interface
solr restart -f
