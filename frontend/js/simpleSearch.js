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
    if (count == 0) {
      this.$button.prop('disabled', true);
      this.$button.find(".filterHits").empty();
      this.deactivate();
    } else {
      this.$button.prop('disabled', false);
      this.$button.find(".filterHits").empty().append(`(${count})`);
    }
  }
}

// all filter buttons stored globally
let filterButtons = new Map();

// doc ready
$(function () {
  // wrapper function that performs search with the correct parameters.
  function simpleSearch(filter) {
    search($("#query").val(), filter, $("#results"), $(".template.result"));
  }

  $("#search").click(simpleSearch.bind($("#search"), "all"));

  // Performs search when 'enter' key is pressed
  $("#query").keypress(function (event) {
    if (event.which == 13)
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
});

// Input: query string, results container, result HTML template
// Effect: makes an AJAX call to the server to get the results of the
// query, and then injects results into the DOM
function search(queryStr, filter, $container, $template) {
  if (queryStr.length == 0) return;

  let data = {
    q: queryStr,
    qf: "search",
    fl: "story_id, story_author, story_descendants, story_score, story_time, story_title, story_content, url, url_text",
    wt: "json",
    indent: "false",
    defType: "edismax",
    facet: true,
    "facet.query": "newssite_filter:news",
    "facet.field": "story_type",
  };

  data["fq"] = "story_type:askhn";

  $.ajax({
    type: "GET",
    url: "http://localhost:8983/solr/hackersearch/select",
    dataType: "json",
    data: data,
    success: function (data) {
      renderResults(data.response, data.facet_counts, filter, $container, $template);
    },
  });
}

// Input: JSON array of results, results container, result HTML template
// Effect: Replaces results container with new results, and renders the appropriate HTML
function renderResults(response, facet, filter, $container, $template) {
  function arrayNextElem(array, elem) {
    return array[array.findIndex(e => e === elem) + 1];
  }

  filterButtons.get("all").setCount(response.numFound);
  filterButtons.get("normal").setCount(arrayNextElem(facet.facet_fields.story_type, "normal"));
  filterButtons.get("askhn").setCount(arrayNextElem(facet.facet_fields.story_type, "askhn"));
  filterButtons.get("showhn").setCount(arrayNextElem(facet.facet_fields.story_type, "showhn"));
  filterButtons.get("launchhn").setCount(arrayNextElem(facet.facet_fields.story_type, "launchhn"));
  filterButtons.get("news").setCount(facet.facet_queries["newssite_filter:news"]);

  // set active button
  filterButtons.forEach((value, _) => {
    value.deactivate();
  });
  filterButtons.get(filter).activate();

  $("#queryInfo").empty().append(`Found ${response.numFound} results.`);
  // the results
  $container.empty(); // if there are any previous results, remove them
  $.each(response.docs, function (_, doc) {
    let result = $template.clone();
    let storyUrl = "https://news.ycombinator.com/item?id=" + doc.story_id;
    result
      .find(".title > a")
      .prop("href", storyUrl)
      .append(doc.story_title);
    if (doc.url) {
      // story has URL
      result.find(".url") // only the domain
        .prop("href", doc.url)
        .append(`(${new URL(doc.url).hostname})`);
    } else {
      result.find(".url") // only the domain
        .prop("href", storyUrl)
        .append(`(${new URL(storyUrl).hostname})`);
    }
    if (doc.story_content) {
      result.find(".content").append(maxWords(doc.story_content, 30));
    } else if (doc.url_text) {
      result.find(".content").append(maxWords(doc.url_text, 30));
    }
    result.find(".result-footer")
      .append(`${doc.story_score} points | ${doc.story_author} | ${doc.story_descendants} comments`);
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
