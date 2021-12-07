#!/bin/sh
QUERIES_DIR="../querries"

queries="eclipse"

N_DOCS=2



for query in $queries
do
  file_name=$query"_qrels.txt"
  if [ -f $file_name ]; then
    read -p "File $file_name already exists. Overwrite? " -n 1 -r
    echo    # New line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      $QUERIES_DIR/$query.sh $N_DOCS > $query"_qrels.json"
    fi
  else
    $QUERIES_DIR/$query.sh $N_DOCS > $query"_qrels.json"
  fi
done
