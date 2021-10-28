import fetch from "node-fetch";
import { Readability } from "@mozilla/readability";
import { JSDOM } from "jsdom";

async function getWebsiteHtml(url) {
  const content = await fetch(url);
  const websiteHtml = await content.text();
  return websiteHtml;
}

export async function cli(args) {
  if (args < 3) {
    console.error("Please gibbe args [url]");
    process.exit(1);
  }

  const url = args.at(2);
  const websiteHtml = await getWebsiteHtml(url);
  var doc = new JSDOM(websiteHtml, {
    url: url,
  });

  let reader = new Readability(doc.window.document);
  let article = reader.parse();

  console.log(article.textContent);
}
