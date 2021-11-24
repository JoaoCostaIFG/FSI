.PHONY: all
all: get_data data.db

.PHONY: get_data
get_data: stories.json comments.json html_content.json

stories.json:
	@# Get the stories of the dataset.
	@# This data is divided into multiple JSON files that we join into 1
	@# single JSON array
	@echo "Getting stories"
	@dataset_pipeline/get_stories.sh
	@# filter the stories by following metrics:
	@# - select alive posts (not dead and not deleted)
	@# - that haven't "failed" => score higher than 5
	@#   (which means they could've made it to the front page)
	@# - that were posted in 2019 (https://time.is/Unix_time_converter)
	@#   (1546300800 == Jan. 1 2019 UTC)
	@#   (1577836800 == Jan. 1 2020 UTC)
	@echo "Filtering stories"
	@dataset_pipeline/filter_stories.sh

comments.json:
	@# Download the top 2 comments of all posts.
	@# Only keep those that haven't been deleted and are 'alive'.
	@echo "Getting comments"
	@dataset_pipeline/get_comments.sh

html_content.json:
	@# Fetch the main textual content of stories that have urls.
	@# This data is compressed using sed and tr:
	@#  - fetch text content in a human-readable fashion
	@#  - escape characters for JSON storage/parsing
	@#  - make the content fit into a single line
	@#  - remove non-printable characters
	@#  - compress blank spaces
	@echo "Getting website content"
	@dataset_pipeline/get_site_content.sh

data.db:
	@# Take the 3 generated JSON files: stories.json,
	@# comments.json, and html_content.json, filter them
	@# (dropping collumns, treating null values, etc...),
	@# and attribute categories to the stories.
	@# Afterwards, insert the content into a sqlite3 database.
	@echo "Data post-processing and database generation"
	@dataset_pipeline/generate_database.py

data_characterization:
	@# Usage: plot.py [true|false] [out_folder]
	@# By default, reads the database file (data.db) and plots different
	@# kinds of graphs and shows it on screen.
	@# An argument, `show`, can be given to specify wether the plots are to be
	@# shown (shown=true) or to be saved as png files (shown=false).
	@# If `show` is set to false, a second argument can be specified, out_folder,
	@# which defines which folder the plots will saved into. The default value
	@# for this argument is docs/plots/
	@echo "Generating data characterization information"
	@plot.py

.PHONY: clean
clean:
	rm -f stories.json comments.json html_content.json data.db

.PHONY: docker_build
docker_build:
	docker build . -t pri_solr_g33

.PHONY: docker_run
docker_run:
	docker run -p 8983:8983 -it pri_solr_g33
