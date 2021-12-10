FROM solr:8.10

COPY ./hackersearch.json /data/hackersearch.json

COPY ./startup.sh /scripts/startup.sh

COPY ./mysynonyms.txt /data/mysynonyms.txt

COPY ./hackersearch_schemaless.json /data/hackersearch_schema.json

ENTRYPOINT ["/scripts/startup.sh"]
