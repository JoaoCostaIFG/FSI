#!/bin/sh
QUERIES_DIR="../querries"

queries="eclipse"



for query in $queries
do
  file_name=$query"_qrels.txt"
  if [ -f $file_name ]; then
    read -p "File $file_name already exists. Overwrite? " -n 1 -r
    echo    # New line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      $QUERIES_DIR/$query.sh 50 > $query"_qrels.txt"
    fi
  else
    $QUERIES_DIR/$query.sh 50 > $query"_qrels.txt"
  fi
done
