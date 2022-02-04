+++
title = "How to Build a Personal Webpage from Scratch"
description = "An opinionated guide on how to build and deploy a modern static webpage."
weight = 0
date = 2022-02-03
draft = true

[extra]
toc = true

[taxonomies]
tags = ["web", "css", "templating", "deployment"]
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
On the other hand, any webpage which allows you to log-in and have user-specific state is a dynamic webpage.
The majority of web pages on the internet are dynamic webpages.

When building a static webpage, you can simply prepare the entire webpage as a directory containing files.
In fact, you can make a minimal webpage (using your own device as the server) simply by writing a bit of HTML with no CSS or JavaScript: create a file named `index.html` with the contents
```
<html><body>content</body></html>
```
and, when you double-click on the file, it should open in your browser and show a (rather minimal) page displaying the line "content".

Dynamic webpages are built in a similar way, except rather than generating the pages in advance, the files sent to the visitor are generated as they are requested.
A dynamic webpage will typically have a [database](https://en.wikipedia.org/wiki/Database) used to store the site information, and a web server which uses the database to generate content when requested by the user.
This allows substantially more flexibility in content delivery (e.g. webpage state, customization for the viewer, etc.) since the content delivered to the webpage can depend on arbitrary variables whose values are unknown when creating the site.
This also allows procedural generation of content, which avoids repetitive code.
The main downside is that, since the pages need to be generated for each visitor, dynamic websites are typically more resource intensive.

### Why static webpages?
However, for a personal blog or site used primarily to _distribute_ information, rather than collect it, dynamic content generation is not necessary!
Here is a short list of reasons why you should prefer simple static webpages (if you do not already know that you require a dynamic webpage):

- __Longevity.__
  A static webpage is just a collection of files, which you should also have saved on your computer.
  So even in the worst case scenario - say your template manager suddenly ceases to exist, and your website is simultaneously taken online - you still have the files for your webpage and you can just put them up somewhere else.
  If you maintain a dynamic webpage, you need to keep the required tools up to date otherwise everything will cease to work.
- __Portability.__
  If you decide that you want to host your webpage somewhere else, this is relatively straightforward to do.
- __Security.__
  Since static webpages are substantially simpler, they have a smaller attack surface and are more secure.
  There is no underlying server serving requests, or processing user input.
  Even in hosted situations, there can be problems with the underlying content management system.
  For example, many Wordpress sites [were compromised](https://www.bleepingcomputer.com/news/security/over-90-wordpress-themes-plugins-backdoored-in-supply-chain-attack/) through an exploit which targeted the plugin system.

### Template processing
One downside of manually preparing a webpage is that there is often a large amount of repetition: for example, each [article](/tags/) on this webpage has different content but many shared layout features.
In order to simplify this process, a common technique is to use a [template processor](https://en.wikipedia.org/wiki/Template_processor).
This is a program which takes files written in a templating language (such as [Jinja](https://jinja.palletsprojects.com/en/3.0.x/templates/) or [Tera](https://tera.netlify.app/)), combined with content files written in a markup language (such as [Markdown](https://en.wikipedia.org/wiki/Markdown)) and converts them into HTML, CSS, and JavaScript files.
You first prepare the templates, then write the content files, and then use the template processor to generate the webpage files.

### Static website components
There are three main components to static website generation:

1. [__templating__](#website-templating-with-zola):
  You need to choose a templating engine and then prepare the website template.
  I am personally a fan of [Zola](https://getzola.org); some other common options are [Jekyll](https://jekyllrb.com/) and [Hugo](https://gohugo.io/).
2. [__content__](#crash-course-in-html-and-css):
  A website needs content!
  You need to write base HTML files and CSS style sheets, as well as the webpage content.
  All the templating engines I mentioned above support Markdown.
3. [__deployment__](#deployment-with-github-and-cloudflare-pages):
  While it is possible (and not too difficult) to host your own static site server, it is typically easiest to use static site hosting.
  I use [Cloudflare Pages](https://pages.cloudflare.com/).
  You might also be interested in [GitHub Pages](https://pages.github.com/) or [Netlify](https://www.netlify.com/).

I'll discuss these three components in the following sections, along with some additional topics in the [final section](#future-steps).

## Prerequisites
### Text editors
HTML is a [markup language](https://en.wikipedia.org/wiki/Markup_language), which means that the text represents content, rather than being the content visually.
Other well-known markup languages are [Markdown](https://en.wikipedia.org/wiki/Markdown) and [LaTeX](https://en.wikipedia.org/wiki/LaTeX).

Therefore when writing content for your webpage, it is important to use an editor which accurately represents the contents of the file you are editing.
This is in contrast to software such as Microsoft Word, in which the content that you enter on the page is different than the underlying representation.
Some popular graphical text editors include [Atom](https://atom.io) and [Sublime Text](https://www.sublimetext.com).
If you do not want to install anything, [Notepad](https://www.microsoft.com/en-us/p/windows-notepad/9msmlrh6lzf3#activetab=pivot:overviewtab) is a built-in text editor on Windows, and [TextEdit](https://support.apple.com/en-ca/guide/textedit/welcome/mac) is built-in on macOS.
For command-line editors, you could consider [Neovim](https://neovim.io) or [Emacs](https://www.gnu.org/software/emacs/).


### Command line interface
If you have a Linux machine, you are probably already familiar with the command line and have a preferred terminal.
On macOS, the command line behaves similarly - the default application is [Terminal](https://en.wikipedia.org/wiki/Terminal_(macOS)), which is built-in on every Mac.
On Windows, if you want a full UNIX command-line interface, you can use [WSL](https://docs.microsoft.com/en-us/windows/wsl/install).

### Git version control
A standard tool used in software development is [git](https://git-scm.com).
Essentially, git is a tool used for [distributed revision control](https://en.wikipedia.org/wiki/Version_control#Distributed_revision_control): in other words, it has functionality to save snapshots of your current projects, distribute your projects or import other projects, and collaborate with others effectively.
My preferred resource to learn about git is the [git webpage](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control).

If you are on a UNIX-like device, check that Git is installed by running
```
git --version
```
in an interactive shell.
If not, you either need to install it and ensure that it is accessible (i.e. on your `PATH`).

### Using GitHub instead
Note that you can get away with not having any of the above tools by using [GitHub](https://github.com) directly as a text editor as well as a Git interface.
If your website is also hosted using [GitHub Pages](https://pages.github.com/), then you do not need to install any software to have your repository built automatically into your webpage!


## Crash Course in HTML and CSS
I'm going to assume you know some basics of HTML and CSS.
There are lots of tutorials online; here is a [nice one](https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/).
I'd recommend you read the articles on [HTML basics](https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/HTML_basics) and [CSS basics](https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/CSS_basics), plus any of the other articles you might require.

In this section, I'll give a very streamlined description of setting up a basic functional blog, with a landing page and page to display your posts.

### Getting started
Let's start with a rather minimal HTML file.
Call it `index.html` in your (currently empty) website folder.
```
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width">

    <title>Example Webpage</title>
    <meta name="description" content="An example webpage.">
    <meta name="author" content="Alex Rutar">
  </head>
  <body>
    <header>
      Example Webpage
    </header>
    <nav>
      <a href="writing.html">Writing</a>
      <a href="index.html">About</a>
    </nav>
    <article>
      <h1>Welcome to my webpage</h1>
      <p>This is some content!</p>
    </article>
  </body>
</html>
```
This isn't the most barebones possible HTML file, but it is a good _modern_ starting point for all HTML content on your site.
Here's an explanation of some of the tags:

- `<meta charset="utf-8">`: declare that the content is encoded in [UTF-8](https://en.wikipedia.org/wiki/UTF-8), which allows us to use unicode when writing content.
  This is necessary so the content does not get interpreted as something like [ASCII](https://en.wikipedia.org/wiki/ASCII) and cause errors.
  Hopefully your text editor supports unicode...
- `<meta name="viewport" content="width=device-width">` ensures that, if this page is opened on a browser with a small screen, it will not be incredibly zoomed out.
  This is the bare minimum required so your page looks passable on a phone.
  You can read a bit about this [here](https://developer.mozilla.org/en-US/docs/Web/HTML/Viewport_meta_tag).
- `<title>`, `<meta name = "description" ...>`, `<meta name="author" ...>`: title, a short page description, and the author
- `<nav>...</nav>`: website navigation
- `<article>...</article>`: the 'content' of the page, i.e. your actual article or blog post but without the navigation, header, footer, etc.

Now if you open the file `index.html` you should get a page with two links at the top: "About", and "Writing".
Currently the "Writing" link does nothing, since we need to create that page.
Create a file called `writing.html` and populate it with pretty much the same contents as `index.html`, but replace the `<article>...</article>` with something slightly different, say
```
<article>
  <h1>Some things I've written</h1>
  <p>Nothing here yet...</p>
</article>
```
You can also change the `<title>` in this new page, as well.
Now, if you click on the navigation links, we have two working pages!

Note that the link attribute `href="writing.html"` specifies a _relative link_, i.e. the file path is taken relative to the directory that the file in which the link sits.
Later, we will replace this with `href="/writing.html"`, which will give a link to the root of your website.
However, when browing files on your device, `/writing.html` will (attempt to) link to the root of your filesystem directory, which is not what you want!


### Styling the page
Well, we have a functional webpage, but it would be nice to make everything look a bit better.
Create a file `style.css`, and add the line
```
<link rel="stylesheet" type="text/css" href="style.css">
```
to the `<head>` of both HTML documents.
This tells the browser to look for a file `style.css` in the same directory as the file, which contains styling information.
While it is possible to define style inline in the HTML, this is bad practice since it is harder to maintain (HTML is for the semantic content, whereas CSS is for style).
Also, you should add some more content to the `<article>` section: perhaps a few more headers `<h2>...</h2>` and links `<a href="...some url...">my link</a>`.

Let's begin with some basic styling.
First, add
```
body {
  margin: 0 auto;
  max-width: 50em;
  min-width: 0;
  padding: 0 10px 25px;
  font-family: "Helvetica", "Arial", sans-serif;
}
```
to the file `style.css`.
This centres the text body, prevents it from being too wide on large screens, ensures there is a bit of a space on the boundary when the screen is small, and finally sets a new font (rather than the usual default Times New Roman).
The `min-width: 0` is useful to prevent large elements from (accidentally) making the page very wide on screens narrower than 50em.

We can also adjust the spacing so that the text is laid out a bit more nicely:
```
body {
  line-height: 1.5;
  padding: 4em 1em;
}

h2 {
  margin-top: 1em;
  padding-top: 1em;
}
```
Or even adjust the colour of the text itself to something a bit more pleasant:
```
body {
  color: #444;
}
h1, h2, strong {
  color: #222;
}
```
Finally, let's add a bit of character by styling the links:
```
a {
  color: #ffa64d;
}
```
Our webpage looks a bit cleaner now!

### Layout with CSS Grid
However, we need to address some more serious layout problems: currently, the navigation is way too small, and the header does not stand out at all.
To fix this, we are going to use a relatively new CSS technique known as [CSS Grid](https://developer.mozilla.org/en-US/docs/Web/CSS/grid).
Essentially, grid allows you to specify a layout in a parent element, and then place the child elements inside this layout.

First, let's specify the general layout of our grid.
We want three sections: a header in the top left (for our title), a navivation bar in the top right, and then a main area containing all the content of the site.
Let's target the `<body>` tag to set up this grid:
```
body {
  display: grid;
  row-gap: 5px;
  grid-template-columns: auto auto;
  grid-template-rows: 60px auto;
  grid-template-areas:
    "header nav"
    "ct ct"
}
```
Let's break down what this is specifying.

- `display: grid`: this element is specifying a grid layout for its children.
- `row-gap: 5px`: have some space between the rows
- `grid-template-columns: auto auto`: determine the width of the columns automatically
- `grid-template-rows: 60px auto`: set the first row (containing the header and navigation bar) to have height 60 pixels, and the second row to be sized automatically based on the content
- `grid-template-areas: ...` names the areas: we have `header` in the top left, `nav` in the top right, and `ct` everywhere else (spanning both columns).
  Note that the names can be whatever you would like (there is no special meaning assigned to using `header` and `nav`).

Now, let's assign our child elements to the areas in this grid, and do a bit of styling.
```
header {
  grid-area: header;
  margin: 0;
  justify-self: left;
  align-self: end;
}
nav {
  grid-area: nav;
  justify-self: right;
  align-self: end;

}
nav a {
  margin-left: 20px;
  text-align: right;
}
article {
  grid-area: ct;
}

```
We want the header to be justified to the left, the nav bar to be justified to the right, and links in the nav bar to have a bit of extra space around them
Note that `align-self: end` means that, within the grid row, we want to be placed as late as possible.
This is important since the row has height 60px, and without this argument, our header and navigation bar would be placed adjacent to the top of the screen!

### Responsive design
Our layout is great, but now we might have some problems on small screens!
The main problem is that if the screen is narrow, our header and navigation bar will start folding over itself.
To fix this, we can use [media queries](https://developer.mozilla.org/en-US/docs/Web/CSS/Media_Queries/Using_media_queries).
This is CSS which is applied only when the query is satisfied: in this situation, we want these rules when the screen is narrow (less than 430 pixels wide).

Here, we only change the styling a bit:

- we now place the header on top of the navigation bar by changing the grid layout in the body
- centre the header and navigation bar
- remove the assymetric styling on the navigation links

This is done with the following CSS code.
```
@media screen and (max-width: 430px) {
  body {
    grid-template-columns: auto;
    grid-template-rows: 30px 20px auto auto;
    grid-template-areas:
    "header"
    "nav"
    "ct"
  }

  header, nav {
    justify-self: center;
  }
  nav a {
    margin: 0 10px;
  }
}
```
Now, our webpage also looks respectable even when viewed on tiny phone screens!

### More resources
In my opinion, the best way to learn more about HTML and CSS is to take a website which you like and use the "Inspect Element" functionality in your browser to view the source code.
The [MDN Web Docs](https://developer.mozilla.org/en-US/) are an incredibly rich resource which contain almost everything you might want to know about web development.
Whenever I need to look anything up, that's where I start.

If your browser is Safari on macOS, you can enable some nice development features with the [Safari developer tools](https://support.apple.com/en-ca/guide/safari/sfri20948/mac) option.
For example, this allows you to emulate different browsers, and enter a "responsive design mode" which allows you to manually modify the screen size and view how your webpage will change.

Firefox also has similar functionality built in to the [Firefox developer tools](https://developer.mozilla.org/en-US/docs/Tools), and the Google Chrome browser in [Chrome DevTools](https://developer.chrome.com/docs/devtools/).


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

### Future steps
## Deployment with GitHub and Cloudflare Pages
## Other miscellaneous topics
### Custom domain setup
There are a few parts to setting up a custom domain.
First, you need to register a domain name, and then you need to set up a [DNS](https://en.wikipedia.org/wiki/Domain_Name_System) to associate your domain name with the address where your webpage is hosted.

#### Domain Name Registration
[ICANN](https://www.icann.org/registrants) is the main body responsible for regulating domain name registration.
In terms of domain registrars, I would recommend one of the following:

- [Cloudflare Registrar](https://www.cloudflare.com/en-ca/products/registrar/)
- [AWS Route 53](https://aws.amazon.com/route53/)
- [Namecheap](https://www.namecheap.com)

I would definitely be careful with other hosts - certain popular domain registrars engage in [shady practices](https://news.ycombinator.com/item?id=24506303) such as registering domains that you look up on their site so that they can make you pay more money for them!

#### Setting up DNS on Cloudflare
For convenience, since our site is already hosted on Cloudflare, let's use Cloudflare for DNS as well.

### Creating favicons
A [favicon](https://en.wikipedia.org/wiki/Favicon) is a small image loaded by the browser and displayed on the website tab.
There is a lot of different advice on how to appropriately set favicons, and unfortunately a lot of it is very outdated.
The advise here is based on [this article](https://evilmartians.com/chronicles/how-to-favicon-in-2021-six-files-that-fit-most-needs).

These days, modern browsers support .svg favicons and this format is easiest way to add a favicon to your webpage: it is lightweight and scales properly.
There are lots of tools available to create these images - I used [this site](https://formito.com/tools/favicon).
You can also just download an icon from a place like [font awesome](https://fontawesome.com/v5.15/icons?d=gallery&p=2&m=free) - there are a lot of options.
There's a [web-hosted implementation](https://jakearchibald.github.io/svgomg/) of the [svgo tool](https://github.com/svg/svgo) which is useful for compressing your .svg file.

To add the favicon to our webpage, first copy the icon file, say `icon.svg`, to the `static/` folder.
Then add the following line to the `<head>` of your base template.
```
<link rel="icon" href="/icon.svg" type="image/svg+xml">
```
This tells the browser that there's an icon located at `icon.sv`, and that it's an .svg file.

If you also want to support older browsers, you need to create a `favicon.ico` file.
You can probably find a converter online, or use [inkscape](https://inkscape.org) and [imagemagick](https://imagemagick.org/index.php) (inkscape has high-quality .svg to .png conversion, and then you can use imagemagick to convert the .png to the .ico file).
If you have the `imagemagick` and `inkscape` tools installed on your command line, you can run
```
inkscape ./icon.svg --export-width=32 --export-filename="./tmp.png"
convert ./tmp.png ./favicon.ico
rm ./tmp.png
```
to convert `icon.svg` into the `favicon.ico` file.
Now tell the browser that this file exists with
```
<link rel="icon" href="/favicon.ico" sizes="any">
```
in the `<head>` of your base template.

If you wish to support more devices, I'd recommend that you read the [favicon article](https://evilmartians.com/chronicles/how-to-favicon-in-2021-six-files-that-fit-most-needs) that I also mentioned earlier.

### site security
- [Mozilla observatory](https://observatory.mozilla.org/analyze/rutar.org)
- Cloudflare `_headers` file
- [HSTS Preload](https://hstspreload.org)
- [GTMetrix](https://gtmetrix.com/analyze.html)

### HTTPS
- [read about why HTTPS](https://doesmysiteneedhttps.com/)
