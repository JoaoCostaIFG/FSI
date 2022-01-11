class FilterButton {
  constructor($button, filter) {
    this.$button = $button;
    this.filter = filter;
    this.setCount(0);
  }

  getButton() {
    return this.$button;
  }

  getFilter() {
    return this.filter;
  }

  getCount() {
    return this.count;
  }

  activate() {
    this.$button.addClass("filterButtonActive");
  }

  deactivate() {
    this.$button.removeClass("filterButtonActive");
  }

  setCount(count) {
    this.count = count;
    if (count === 0) {
      this.$button.prop('disabled', true);
      this.$button.find(".filterHits").empty();
      this.deactivate();
    } else {
      this.$button.prop('disabled', false);
      this.$button.find(".filterHits").empty().text(`(${count})`);
    }
  }
}

class LoadMoreButton {
  constructor($button) {
    this.$button = $button;
    this.currentFilter = "all";
    this.reset();
  }

  getCurrentFilter() {
    return this.currentFilter;
  }

  setCurrentFilter(filter) {
    this.currentFilter = filter;
  }

  getCount() {
    return this.count;
  }

  getButton() {
    return this.$button;
  }

  incrementCount() {
    this.count += 10;
    return this.count;
  }

  reset() {
    this.count = 10;
    this.hide();
  }

  hide() {
    this.$button.hide();
  }

  show() {
    this.$button.show();
  }
}

// all filter buttons stored globally
let filterButtons = new Map();
let loadMoreBtn;

// doc ready
$(function () {
  // wrapper function that performs search with the correct parameters.
  function simpleSearch(filter) {
    search($("#query").val(), filter, $("#results"), $(".template.result"));
  }

  $("#search").click(simpleSearch.bind($("#search"), "all"));

  // Performs search when 'enter' key is pressed
  $("#query").keypress(function (event) {
    if (event.which === 13)
      simpleSearch("all");
  });

  function prepareFilterButton($button, filter) {
    let ret = new FilterButton($button, filter);
    $button.click(simpleSearch.bind($button, filter));
    ret.deactivate();
    return ret;
  }

  filterButtons.set("all", prepareFilterButton($("#allFilter"), "all"));
  filterButtons.set("normal", prepareFilterButton($("#normalFilter"), "normal"));
  filterButtons.set("askhn", prepareFilterButton($("#askFilter"), "askhn"));
  filterButtons.set("showhn", prepareFilterButton($("#showFilter"), "showhn"));
  filterButtons.set("launchhn", prepareFilterButton($("#launchFilter"), "launchhn"));
  filterButtons.set("news", prepareFilterButton($("#newsFilter"), "news"));

  loadMoreBtn = new LoadMoreButton($("#loadMore"));
  loadMoreBtn.getButton().click(function () {
    loadMoreBtn.incrementCount();
    simpleSearch(loadMoreBtn.getCurrentFilter());
  });
});

// Input: query string, results container, result HTML template
// Effect: makes an AJAX call to the server to get the results of the
// query, and then injects results into the DOM
function search(queryStr, filter, $container, $template) {
  if (queryStr.length === 0) return;

  if (filter !== loadMoreBtn.getCurrentFilter()) {
    loadMoreBtn.reset();
    loadMoreBtn.setCurrentFilter(filter);
  }

  let data = {
    q: queryStr,
    qf: "search",
    fl: "story_id, story_author, story_descendants, story_score, story_time, story_title, story_content, url, url_text",
    wt: "json",
    indent: "false",
    defType: "edismax",
    rows: loadMoreBtn.getCount(),
    facet: true,
    "facet.query": "newssite_filter:news",
    "facet.field": "story_type",
  };

  switch (filter) {
    case "normal":
      data["fq"] = "story_type:normal";
      break;
    case "askhn":
      data["fq"] = "story_type:askhn";
      break;
    case "showhn":
      data["fq"] = "story_type:showhn";
      break;
    case "launchhn":
      data["fq"] = "story_type:launchhn";
      break;
    case "news":
      data["fq"] = "newssite_filter:news";
      break;
    default:
      break;
  }

  $.ajax({
    type: "GET",
    url: "http://localhost:8983/solr/hackersearch/select",
    dataType: "json",
    data: data,
    success: function (data) {
      console.log(data);
      renderResults(data.response, data.facet_counts, filter, $container, $template);
    },
  });
}

// Input: JSON array of results, results container, result HTML template
// Effect: Replaces results container with new results, and renders the appropriate HTML
function renderResults(response, facet, filter, $container, $template) {
  function arrayNextElem(array, elem) {
    let idx = array.findIndex(e => e === elem);
    if (idx < 0 || idx + 1 >= array.length) return 0;
    return array[idx + 1];
  }

  if (filter === "all") {
    filterButtons.get("all").setCount(response.numFound);
    filterButtons.get("normal").setCount(arrayNextElem(facet.facet_fields.story_type, "normal"));
    filterButtons.get("askhn").setCount(arrayNextElem(facet.facet_fields.story_type, "askhn"));
    filterButtons.get("showhn").setCount(arrayNextElem(facet.facet_fields.story_type, "showhn"));
    filterButtons.get("launchhn").setCount(arrayNextElem(facet.facet_fields.story_type, "launchhn"));
    filterButtons.get("news").setCount(facet.facet_queries["newssite_filter:news"]);
  }

  // set active button
  filterButtons.forEach((value, _) => {
    value.deactivate();
  });
  filterButtons.get(filter).activate();

  $("#queryInfo").empty().text(`Showing ${response.docs.length} results out of ${response.numFound}.`);
  if (response.docs.length < response.numFound) loadMoreBtn.show();
  else loadMoreBtn.hide();

  // the results
  $container.empty(); // if there are any previous results, remove them
  $.each(response.docs, function (i, doc) {
    // small division every 10 items (load more results)
    if (i > 0 && i % 10 == 0) {
      $container.append("<hr>");
    }

    let result = $template.clone();
    let storyUrl = "https://news.ycombinator.com/item?id=" + doc.story_id;
    result
      .find(".title > a")
      .prop("href", storyUrl)
      .text(doc.story_title);
    let url = doc.url ? doc.url : storyUrl; // stome stories don't have an URL
    result.find(".url") // only the domain
      .prop("href", url)
      .text(`(${new URL(url).hostname})`);
    if (doc.story_content) {
      result.find(".content").text(maxWords(doc.story_content, 30));
    } else if (doc.url_text) {
      result.find(".content").text(maxWords(doc.url_text, 30));
    }
    result.find(".result-footer")
      .text(`${doc.story_score} points | ${doc.story_author} | ${doc.story_descendants} comments`);
    result.removeClass("template");
    $container.append(result);
  });
}

// Cuts off lengthy content to a given maximum number of words
// Input: string of words, maximum number of words
// Effects: none
// Output: the trimmed words
function maxWords(content, max) {
  let words = content.split(" ", max);
  let cutContent = "";
  for (let idx = 0; idx < words.length; idx++) {
    cutContent += words[idx];
    cutContent += idx + 1 == words.length ? "" : " ";
  }
  return cutContent + "...";
}
