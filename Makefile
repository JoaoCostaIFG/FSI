.PHONY: all
all: get_data data.db

.PHONY: get_data
get_data: stories.json comments.json html_content.json

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

data.db:
	@echo "Data post-processing and database generation"
	@dataset_pipeline/generate_database.py

data_characterization:
	@echo "Generating data characterization information"
	@plot.py

.PHONY: clean
clean:
	rm -f stories.json comments.json html_content.json data.db
