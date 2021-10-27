.PHONY: all
all:
	git clone "https://github.com/massanishi/hackernews-post-datasets"
	jq -s "hackernews-post-datasets-main/*.json"
