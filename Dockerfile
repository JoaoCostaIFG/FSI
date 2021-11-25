FROM solr:8.10

COPY hackersearch.json /data/hackersearch.json

#COPY simple_schema.json /data/simple_schema.json

COPY startup.sh /scripts/startup.sh

EXPOSE 8983

ENTRYPOINT ["/scripts/startup.sh"]
