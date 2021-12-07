#!/bin/sh

IFS=$'\n'
for title in $(jq -r '.response.docs[].story_title' $1); do
  read -p "Is title $title relevant?" -n 1 -r
  echo    # New line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    val="true"
  else
    val="false"
  fi

  [ $keys ] && keys="$keys|$title" || keys="\"$title"
  [ $relevants ] && relevants="$relevants|$val" || relevants="\"$val"
done

relevants=$relevants\"
keys=$keys\"

A=$(printf '(%s | split("|") ) as $keys | (%s | split("|") ) as $vals | [$keys, $vals] | transpose' $keys $relevants)
echo $A
jq -n $A
