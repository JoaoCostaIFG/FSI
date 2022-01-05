FROM solr:8.10

COPY ./web.xml /opt/solr/server/solr-webapp/webapp/WEB-INF/web.xml

COPY ./hackersearch.json /data/hackersearch.json

COPY ./startup.sh /scripts/startup.sh

COPY ./mysynonyms.txt /data/mysynonyms.txt
COPY ./newssites.txt /data/newssites.txt
COPY ./newsword.txt /data/newsword.txt

COPY ./hackersearch_schema.json /data/hackersearch_schema.json

ENTRYPOINT ["/scripts/startup.sh"]
