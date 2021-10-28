import fetch from "node-fetch";
import AbortController from 'abort-controller';
import { Readability } from "@mozilla/readability";
import { JSDOM } from "jsdom";

async function getWebsiteHtml(url) {
  // 1 sec timeout
  const controller = new AbortController();
  const timeout = setTimeout(() => {
	  controller.abort();
  }, 3000);

  let content;
  try {
    content = await fetch(url, {signal: controller.signal});
  } catch (e) {
    // request timed out
    return null;
  } finally {
    clearTimeout(timeout)
  }

  return content.text();
}

export async function cli(args) {
  if (args < 3) {
    console.error("Please gibbe args [url]");
    process.exit(1);
  }

  const url = args.at(2);
  const websiteHtml = await getWebsiteHtml(url);
  if (websiteHtml == null) process.exit(1);

  var doc = new JSDOM(websiteHtml, {
    url: url,
  });

  let reader = new Readability(doc.window.document);
  let article = reader.parse();

  console.log(article.textContent.trim());
}
