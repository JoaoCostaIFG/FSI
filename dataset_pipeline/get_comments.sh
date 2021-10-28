#!/bin/bash

# prepare output file
out_file_suf="comments.json"

comment_ids="$(mktemp)"
jq '.[].kids[:2]' <stories.json | jq -s add | jq '.[]' |
  awk '{print "url=https://hacker-news.firebaseio.com/v0/item/"$0".json"}' >"$comment_ids"

split -n l/4 "$comment_ids"
rm -f "$comment_ids"

for f in xaa xab xac xad; do
  echo "Spawning $f"

  out_file="${f}_${out_file_suf}"
  rm -f "$out_file"
  curl -s -K "$f" |
    jq 'select(.dead == null and .deleted == null)' >"$out_file" && 
    rm -f "$f" &
done

echo "Waiting subprocesses"
wait

echo "Joining files"
cat -- *"$out_file_suf" | jq -s -c '.' >comments.json
rm -f "xaa_${out_file_suf}" "xab_${out_file_suf}" "xac_${out_file_suf}" "xad_${out_file_suf}"
