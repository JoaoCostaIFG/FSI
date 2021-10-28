.PHONY: get_data
get_data:
	dataset_pipeline/get_stories.sh
	dataset_pipeline/filter_stories.sh
	dataset_pipeline/get_comments.sh
