#!/bin/bash

work() {
  # prepare output file
  out_file="data_${2}.json"
  echo "[" >"$out_file"

  # the first record has id 1
  i=$1
  while [ "$i" -le "$2" ]; do
    # echo "Trying item ${i}"
    item="$(curl -s "https://hacker-news.firebaseio.com/v0/item/${i}.json")"
    if [ "$(echo "$item" | jq '.type')" = '"story"' ]; then
      descendants="$(echo "$item" | jq '.descendants')"
      [ "$descendants" = "null" ] && descendants=0

      if [ "$descendants" -gt 0 ]; then
        # echo "Getting item ${i}"
        echo "${item}," >>"$out_file"
      fi
    fi

    i=$((i + 1))
  done

  printf "]" >"$out_file"
}

if [ "$#" -eq 0 ]; then
  # get total item number
  max_item_id="$(curl -s "https://hacker-news.firebaseio.com/v0/maxitem.json?print=pretty")"
  echo "Found ${max_item_id} items."

  # spawn 30 processes
  step=$((max_item_id / 30))
  i=0
  while [ "$i" -lt 30 ]; do
    start_id=$((step * i + 1))
    end_id=$((start_id + step))
    ./query.sh "$start_id" "$end_id" &

    i=$((i + 1))
  done

  # wait subprocesses
  wait
else
  [ "$#" -ne 2 ] && echo "wut?" && exit 1
  echo "Working on posts from $1 to $2"
  work "$1" "$2"
fi

