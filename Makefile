.PHONY: all
all: stories.json comments.json html_content.json

stories.json:
	@echo "Getting stories"
	@dataset_pipeline/get_stories.sh
	@echo "Filtering stories"
	@dataset_pipeline/filter_stories.sh

comments.json:
	@echo "Getting comments"
	@dataset_pipeline/get_comments.sh

html_content.json:
	@echo "Getting website content"
	@dataset_pipeline/get_site_content.sh
