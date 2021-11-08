#!/bin/bash
#
# Download the top 3 comments of all posts.
# Only keep those that haven't been deleted and are 'alive'.
#

# prepare output file
out_file_suf="comments.json"

# store the top 2 comments of all posts in API request URL form
comment_ids="$(mktemp)"
jq '.[].kids[:2][]' <stories.json |
  awk '{print "url=https://hacker-news.firebaseio.com/v0/item/"$0".json"}' >"$comment_ids"
# split the URL file so we can use 4 jobs to download the data
split -n l/4 "$comment_ids"

# spawn 4 jobs to download the data
for f in xaa xab xac xad; do
  echo "Spawning $f"

  out_file="${f}_${out_file_suf}"
  curl -s -K "$f" |
    jq '. | select((.dead == null or .dead == false) and (.deleted == null or .deleted == false))' >"$out_file" &&
    rm -f "$f" &
done

echo "Waiting subprocesses"
wait

# join files
echo "Joining files"
cat -- *"$out_file_suf" | jq -c -s '.' >"$out_file_suf"

# cleanup
rm -f "$comment_ids" "xaa_${out_file_suf}" "xab_${out_file_suf}" "xac_${out_file_suf}" "xad_${out_file_suf}"
