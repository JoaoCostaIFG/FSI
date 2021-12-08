#!/bin/sh

IFS=$'\n'
for title in $(jq -r '.response.docs[].story_title' $1); do
  read -p "Is title $title relevant?" -n 1 -r
  echo    # New line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    val="true"
  elif [[ $REPLY =~ ^[Nn]$ ]]; then
    val="false"
  else
    val="maybe"
  fi

  [ $relevants ] && relevants="$relevants|$val" || relevants="\"$val"
done
relevants=$relevants\"


jq_vals=$(printf '(%s | split("|") ) as $vals |' $relevants)
jq_content="{docs: [[[.response.docs[].story_id], [.response.docs[].story_title], [.response.docs[].search], \$vals] | transpose[] |"
jq_format="{id: .[0], title: .[1], search: .[2], relevant: .[3]}]}"
Q="$jq_vals$jq_content$jq_format"

jq -r $Q $1 > $2
