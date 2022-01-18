+++
title = "How to Build a Personal Webpage from Scratch"
description = "An opinionated guide on how to build and deploy a modern static webpage."
weight = 0
date = 2022-01-17
draft = true

[extra]

[taxonomies]
tags = ["web", "css", "templating"]
+++
## An overview of static webpage deployment
### What is a static webpage?
This website is a [static web page](https://en.wikipedia.org/wiki/Static_web_page).
Modern webpages are (primarily) composed of three types of files: HTML, CSS, and JavaScript.
Basically,

- HTML specifies the _content_,
- CSS defines the _style_, and
- JavaScript allows _dynamic behaviour_.

Webpages also consist of additional resources, such as images or documents.

Static and dynamic webpages differ in how the files are prepared before they are sent to the visitor.
A static webpage is essentially a _collection of files_ which are sent directly to the webpage visitor, whereas a dynamic webpage typically consists of a database as well as code to generate the files _on the fly_ when they are requested by the visitor.

When building a webpage, one can simply manually prepare the entire webpage as a file directory.
In fact, one can make a minimal webpage simply by writing a bit of HTML with no CSS or JavaScript: create a file named `index.html` with the contents
```
<html><body>content</body></html>
```
and, when you double-click on the file, it should open in your browser and show a (minimal) webpage displaying the line "content".

However, webpages often have a large amount of repetition: for example, each [article](/tags/) on this webpage has different content but the many shared layout features.
In order to make it easier to create new pages, a common technique is to use a [template processor](https://en.wikipedia.org/wiki/Template_processor).
This is a program which takes files written in a templating language (such as [Jinja](https://jinja.palletsprojects.com/en/3.0.x/templates/)) and converts them into HTML, CSS, and JavaScript files.
One writes the templates and content files, and then uses the template processor to generate the webpage files.

Dynamic webpages are built in a similar way, except rather than generating the pages in advance, the files sent to the visitor are generated as they are requested.
A dynamic webpage will typically have a [database](https://en.wikipedia.org/wiki/Database) used to store the site information, which is then used to generate the content.
This allows substantially more flexibility in content delivery (e.g. website state, customization for the viewer, etc.) since the content delivered to the webpage can depend on arbitrary variables whose values are unknown when creating the site.
However, since the pages need to be generated for each visitor, dynamic websites are typically slower and more resource intensive.

The most commonly visited web pages on the internet are dynamic webpages.
However, for a personal blog or site, dynamic content generation is not necessary!

### Static website components
There are three main components to static website generation

1. [__templating__](#website-templating-with-zola):
  You need to choose a templating engine and then prepare the website template.
  I am personally a fan of [Zola](https://getzola.org); some other common options are [Jekyll](https://jekyllrb.com/) and [Hugo](https://gohugo.io/).
2. [__content__](#crash-course-in-html-and-css-with-examples):
  A website needs content!
  You need to write base HTML files and CSS style sheets, as well as the webpage content.
3. [__deployment__](#deployment-with-github-and-cloudflare-pages):
  While it is possible (and not too difficult) to host your own static site server, it is typically easiest to use static site hosting.
  I use [Cloudflare Pages](https://pages.cloudflare.com/).
  You might also be interested in [GitHub Pages](https://pages.github.com/) or [Netlify](https://www.netlify.com/).

In this article, I will present the maing

## Website Templating with Zola
The Zola webpage has a nice [article](https://www.getzola.org/documentation/getting-started/overview/) on getting started with Zola.

### Template render order and inheritance
### Custom functions and shortcodes
### Including data files
### Creating tag pages

## Crash Course in HTML and CSS (with examples)
I'm going to assume you know some basics of HTML and CSS.
There are lots of tutorials online; you can find a decent one [here](https://html.com).

### Future steps
In my opinion, the best way to learn HTML and CSS is to start with a simple webpage (for example, this one!), download the content locally, and understand how everything works.
## Deployment with Github and Cloudflare Pages
## Other miscellaneous topics
### custom domain setup
### site security
mozilla observatory, adding headers on cloud flare
### https
