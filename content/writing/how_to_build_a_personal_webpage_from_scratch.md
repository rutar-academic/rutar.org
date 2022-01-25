+++
title = "How to Build a Personal Webpage from Scratch"
description = "An opinionated guide on how to build and deploy a modern static webpage."
weight = 0
date = 2022-01-17
draft = true

[extra]
toc = true

[taxonomies]
tags = ["web", "css", "templating"]
+++
## An overview of static webpage deployment
### What is a static webpage?
Modern webpages are (primarily) composed of three types of files: HTML, CSS, and JavaScript.
Basically,

- HTML specifies the _content_,
- CSS defines the _style_, and
- JavaScript allows _dynamic behaviour_.

Webpages also consist of additional resources, such as images or documents.
When you visit a webpage, your web browser requests the documents from a server.

[Static](https://en.wikipedia.org/wiki/Static_web_page) and [dynamic](https://en.wikipedia.org/wiki/Dynamic_web_page) webpages differ in how the files are prepared before they are sent to the visitor.
A static webpage is essentially a _collection of files_ sitting on the server, which are sent directly to the webpage visitor, whereas a dynamic webpage typically consists of a database as well as code to generate the files _on the fly_ when they are requested by the visitor.

For example, this website is a static webpage.
On the other hand, any webpage which allows you to log-in is a dynamic webpage.
The majority of web pages on the internet are dynamic webpages.

When building a static webpage, you can simply prepare the entire webpage as a file directory.
In fact, you can make a minimal webpage (using your own device as the server) simply by writing a bit of HTML with no CSS or JavaScript: create a file named `index.html` with the contents
```
<html><body>content</body></html>
```
and, when you double-click on the file, it should open in your browser and show a (minimal) webpage displaying the line "content".

Dynamic webpages are built in a similar way, except rather than generating the pages in advance, the files sent to the visitor are generated as they are requested.
A dynamic webpage will typically have a [database](https://en.wikipedia.org/wiki/Database) used to store the site information, which is then used to generate the content.
This allows substantially more flexibility in content delivery (e.g. website state, customization for the viewer, etc.) since the content delivered to the webpage can depend on arbitrary variables whose values are unknown when creating the site.
This also allows procedural generation of content, which avoids repetitive code.
The main downside is that, since the pages need to be generated for each visitor, dynamic websites are typically more resource intensive.

### Template processing
However, for a personal blog or site used primarily to _distribute_ information, rather than collect it, dynamic content generation is not necessary!

One downside of manually preparing a webpage is that there is often a large amount of repetition: for example, each [article](/tags/) on this webpage has different content but many shared layout features.
In order to simplify this process, a common technique is to use a [template processor](https://en.wikipedia.org/wiki/Template_processor).
This is a program which takes files written in a templating language (such as [Jinja](https://jinja.palletsprojects.com/en/3.0.x/templates/) or [Tera](https://tera.netlify.app/)), combined with content files written in a markup language (such as [Markdown](https://en.wikipedia.org/wiki/Markdown)) and converts them into HTML, CSS, and JavaScript files.
You first prepare the templates, then write the content files, and then use the template processor to generate the webpage files.

### Static website components
There are three main components to static website generation

1. [__templating__](#website-templating-with-zola):
  You need to choose a templating engine and then prepare the website template.
  I am personally a fan of [Zola](https://getzola.org); some other common options are [Jekyll](https://jekyllrb.com/) and [Hugo](https://gohugo.io/).
2. [__content__](#crash-course-in-html-and-css-with-examples):
  A website needs content!
  You need to write base HTML files and CSS style sheets, as well as the webpage content.
  All the templating engines I mentioned above support Markdown.
3. [__deployment__](#deployment-with-github-and-cloudflare-pages):
  While it is possible (and not too difficult) to host your own static site server, it is typically easiest to use static site hosting.
  I use [Cloudflare Pages](https://pages.cloudflare.com/).
  You might also be interested in [GitHub Pages](https://pages.github.com/) or [Netlify](https://www.netlify.com/).

I'll discuss these three components in the following sections, along with some additional topics in the [final section](#future-steps).

### A quick note on git
A standard tool used in software development is [git](https://git-scm.com).
Essentially, git is a tool used for [distributed revision control](https://en.wikipedia.org/wiki/Version_control#Distributed_revision_control): in other words, it has functionality to save snapshots of your current projects, distribute your projects or import other projects, and collaborate with others effectively.
My preferred resource to learn about git is the [git webpage](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control).

Here's a quick tutorial on getting started with git.
First, download the installer for your preferred device from the [official site](https://git-scm.com/downloads).
#### Windows
Run the installer with the default options.
On the next page, it's probably best to choose the option __Use Git Bash only__.
In order to start up Git in a project folder, you can right-click in the folder and select __Git Bash Here__.

TODO: write this section.

<!--- TODO: https://www.pluralsight.com/guides/using-git-and-github-on-windows --->

#### UNIX Shell
If you are on a unix-like device, check that Git is installed by running
```
git --version
```
in an interactive shell.
If not, you either need to install it and ensure that it is accessible (i.e. on your `PATH`).



## Website Templating with Zola
The Zola webpage has a nice [article](https://www.getzola.org/documentation/getting-started/overview/) on getting started with Zola.

### Template render order and inheritance
### Custom functions and shortcodes
### Including data files
### Creating tag pages
### Adding a table of contents
```
{% if page.extra.hastoc %}
<h2>Contents</h2>
<div class="toc">
<ol>
  {% for h1 in page.toc %}
  <li><a href="{{h1.permalink | safe}}">{{ h1.title }}</a>
    {% if h1.children %}
    <ol>
      {% for h2 in h1.children %}
      <li><a href="{{h2.permalink | safe}}">{{ h2.title }}</a></li>
      {% endfor %}
    </ol>
    {% endif %}
  </li>
  {% endfor %}
</ol>
</div>
```
In the CSS file, we add the corresponding contents:
```
.toc {
  ol {
    counter-reset: toc-item
  }
  li {
    display: block
  }
  li:before {
    content: counters(toc-item, ".") ". ";
    counter-increment: toc-item
  }
}
```
This ensures that the numbering aligns with our numbering style for the headers.
Now, whenever we want a table of contents, we simply include the tag
```
[extra]
toc = true
```
at the beginning of our article.


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
