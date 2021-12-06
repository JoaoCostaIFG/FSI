FROM solr:8.10

COPY hackersearch.json /data/hackersearch.json

COPY startup.sh /scripts/startup.sh

COPY hackersearch_schema.json /data/hackersearch_schema_1.json

ENTRYPOINT ["/scripts/startup.sh"]
