#!/bin/bash
#
# Fetch the main textual content of stories that have urls.
# This data is compressed using sed and tr:
#  - fetch text content in a human-readable fashion
#  - escape characters for JSON storage/parsing
#  - make the content fit into a single line
#  - remove non-printable characters
#  - compress blank spaces
#

out_file="html_content.json"
rm -f "$out_file"

# filter for stories that have an url
stories="$(mktemp)"
jq -c '.[] | select(.url != null)' <stories.json >"$stories"

# split the stories file so we can use 8 jobs to download the data
split -n l/8 "$stories"

# spawn 8 jobs to download the data
for f in xaa xab xac xad xae xaf xag xah; do
  echo "Spawning $f"

  while read -r item; do
    id="$(echo "$item" | jq -r '.id')"
    url="$(echo "$item" | jq -r '.url')"

    # fetch the text content of the site in a compact format
    html_content="$(readability "$url" 2>/dev/null |  # fetch text content in a human-readable fashion
      sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' |           # escape characters for JSON storage/parsing
      tr '\n' ' ' | tr '\t' ' ' |                     # make the content fit into a single line
      tr -cd "[:print:]" |                            # remove non-printable characters
      sed 's/[ ]\+/ /g')"                             # compress blank spaces

    printf '{"id": %s, "html_content": "%s"}\n' "$id" "$html_content" >> "${f}_${out_file}"
  done <"$f" &
done

echo "Waiting subprocesses"
wait

# join files
echo "Joining files"
cat -- *"$out_file" | jq -c -s '.' >"$out_file"

# cleanup
rm -f "$stories" \
  "xaa" "xaa_${out_file}" "xab" "xab_${out_file}" \
  "xac" "xac_${out_file}" "xad" "xad_${out_file}" \
  "xae" "xae_${out_file}" "xaf" "xaf_${out_file}" \
  "xag" "xag_${out_file}" "xah" "xah_${out_file}"
