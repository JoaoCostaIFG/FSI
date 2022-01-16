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
        "df": "search",
        "rows": 10,
        "spellcheck": "on",
        "spellcheck.collate": "true"
      },
      "last-components": [
        "spellcheck"
      ]
    },
    "update-searchcomponent": {
      "name": "spellcheck",
      "class": "solr.SpellCheckComponent",
      "spellchecker": {
        "classname": "solr.IndexBasedSpellChecker",
        "spellcheckIndexDir": "./spellchecker",
        "field": "spell",
        "buildOnCommit": "true"
      }
    },
    "create-searchcomponent": {
      "name": "suggest",
      "class": "solr.SuggestComponent",
      "suggester": [
        {
          "name": "mySuggester",
          "lookupImpl": "AnalyzingInfixLookupFactory",
          "dictionaryImpl": "DocumentDictionaryFactory",
          "field": "sugg",
          "suggestAnalyzerFieldType": "suggestion_type",
          "buildOnCommit": "true"
        },
        {
          "name": "altSuggester",
          "lookupImpl": "FreeTextLookupFactory",
          "dictionaryImpl": "DocumentDictionaryFactory",
          "field": "sugg",
          "suggestFreeTextAnalyzerFieldType": "suggestion_type",
          "buildOnCommit": "true"
        }
      ]
    },
    "create-requesthandler": {
      "name": "/suggest",
      "class": "solr.SearchHandler",
      "startup": "lazy",
      "defaults": {
        "suggest": "true",
        "suggest.count": "8",
        "suggest.dictionary": ["mySuggester", "altSuggester"]
      },
      components: [
        "suggest"
      ]
    },
    "create-requesthandler": {
      "name": "/mlt",
      "class": "solr.MoreLikeThisHandler",
      "defaults": {
        "mlt.fl": "story_title, story_text, story_type, url",
        "mlt.mintf": 1,
        "mlt.maxdfpct": 10,
        "mlt.minwl": 3,
        "mlt.match.include": false,
        "mlt.interestingTerms": "list"
      }
    }
  }' \
  http://localhost:8983/solr/hackersearch/config

# populate collection
bin/post -c hackersearch /data/hackersearch.json

# restart in foreground mode so we can access the interface
solr restart -f
