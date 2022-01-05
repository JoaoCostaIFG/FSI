// Doc ready
$(function () {
  // Shortcut function that performs search with the correct parameters.
  // Can be called without any arguments inline
  function simpleSearch() {
    search($("#query").val(), $("#results"), $(".template.result"));
  }

  $("#search").click(simpleSearch);

  // Performs search when 'enter' key is pressed
  $("#query").keypress(function (event) {
    if (event.which == 13)
      simpleSearch();
  });
});

// Input: query string, results container, result HTML template
// Effect: makes an AJAX call to the server to get the results of the
// query, and then injects results into the DOM
// Output: void
function search(query, $container, $template) {
  $.ajax({
    type: "GET",
    url: "http://localhost:8983/solr/hackersearch/select",
    dataType: "json",
    data: {
      q: query,
      qf: "search",
      wt: "json",
      fl: "story_id, story_author, story_descendants, story_score, story_time, story_title, story_content, url, url_text",
      indent: "false",
      defType: "edismax",
    },
    success: function (data) {
      renderResults(data.response.docs, $container, $template);
    },
  });
}

// Input: JSON array of results, results container, result HTML template
// Effect: Replaces results container with new results, and renders
// the appropriate HTML
// Output: void
function renderResults(docs, $container, $template) {
  $container.empty(); // If there are any previous results, remove them
  $.each(docs, function (_, doc) {
    let result = $template.clone();
    result
      .find(".title > a")
      .prop("href", "https://news.ycombinator.com/item?id=" + doc.story_id)
      .append(doc.story_title);
    result.find(".url") // only the domain
      .prop("href", doc.url)
      .append(`(${new URL(doc.url).hostname})`);
    result.find(".content").append(maxWords(doc.url_text, 30));
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
