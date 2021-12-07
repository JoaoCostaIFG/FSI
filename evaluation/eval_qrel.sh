#!/bin/sh

relevants=""
IFS=$'\n'
for title in $(jq '.response.docs[].story_title' $1); do
  read -p "Is title $title relevant?" -n 1 -r
  echo    # New line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    relevants="$relevants true"
  else
    relevants="$relevants false"
  fi
done

jq '.response.docs[] += [input]' $1 $relevants
