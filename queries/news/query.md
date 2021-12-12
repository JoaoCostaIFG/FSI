# China querry

The user wants to search news about china instead of blogposts on how one makes
his site available to a chinese audience.
The relevant documents are the ones that refer to news about china.

**Search:** `china +(newssite_filter:news)`

## 10

`http://0.0.0.0:8983/solr/hackersearch/select?indent=true&q.op=OR&q=china%20-(newssite_filter%3Anews)`

## 50

`http://0.0.0.0:8983/solr/#/hackersearch/query?q=china%20-(newssite_filter:news)&q.op=OR&indent=true&rows=50`
