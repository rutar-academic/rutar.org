+++
title = "How to Build a Personal Webpage from Scratch"
description = "An opinionated introduction to designing and deploying a modern static webpage."
weight = 0
date = 2022-02-05
draft = true

[extra]
toc = true

[taxonomies]
tags = ["web", "css", "deployment"]
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
A static webpage is essentially a _collection of files_ sitting on the server, which are sent directly to the webpage visitor, whereas a (server-side{% inline_note() %}This is in contrast to a client-side dynamic webpage which uses Javascript, but only in your web browser.{% end %}) dynamic webpage typically consists of a database as well as code to generate the files _on the fly_ when they are requested by the visitor.

For example, this website is a static webpage.
On the other hand, any webpage which allows you to log-in and have user-specific state is a dynamic webpage.
The majority of web pages on the internet are dynamic webpages.

When building a static webpage, you can simply prepare the entire webpage as a directory containing files.
In fact, you can make a minimal webpage (using your own device as the server) simply by writing a bit of HTML with no CSS or JavaScript: create a file named `index.html` with the contents
```
<html><body>content</body></html>
```
and, when you double-click on the file, it should open in your browser and show a (rather minimal) page displaying the line <q>content</q>.

Dynamic webpages are built in a similar way, except rather than generating the pages in advance, the files sent to the visitor are generated as they are requested.
A dynamic webpage will typically have a [database](https://en.wikipedia.org/wiki/Database) used to store the site information, and a web server which uses the database to generate content when requested by the user.
This allows substantially more flexibility in content delivery (e.g. webpage state, customization for the viewer, etc.) since the content delivered to the webpage can depend on arbitrary variables whose values are unknown when creating the site.
This also allows procedural generation of content, which avoids repetitive code.
The main downside is that, since the pages need to be generated for each visitor, dynamic websites are typically more resource intensive and slower to render.

### Why static webpages?
However, for a personal blog or site used primarily to _distribute_ information, rather than collect it, dynamic content generation is not necessary!
Here is a short list of reasons why you should prefer simple static webpages (if you do not already know that you require a dynamic webpage):

- __Longevity.__
  A static webpage is just a collection of files, which you should also have saved on your computer.
  So even in the worst case scenario - say your web server disappears - you still have the files for your webpage and you can just put them up somewhere else.
  Static webpages are also easier to maintain: if you have a dynamic webpage, you need to keep the required tools up to date otherwise everything will cease to work.
- __Portability.__
  If you decide that you want to host your webpage somewhere else, this is straightforward to do.
  Static webpages are also simple enough that you can host them yourself on a low-power device!
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

1. __Templating__.
  You should choose a templating engine and then prepare the website template.
  I am personally a fan of [Zola](https://getzola.org); some other common options are [Jekyll](https://jekyllrb.com/) and [Hugo](https://gohugo.io/).
2. __Content__.
  A website needs content!
  You need to write base HTML files and CSS style sheets, as well as the webpage content.
3. __Deployment__.
  While it is possible (and not too difficult) to host your own static site server, it is typically easiest to use static site hosting.
  I use [Cloudflare Pages](https://pages.cloudflare.com/).
  You might also be interested in [GitHub Pages](https://pages.github.com/) or [Netlify](https://www.netlify.com/).

Of course, templating is mainly a convenience feature, and not strictly necessary when making a small website.
I'll discuss the other two components in the following sections, along with some additional topics in the [final section](#further-topics).
<!-- You can read more about templating TODO: add link -->

### A note on editing text
HTML is a [markup language](https://en.wikipedia.org/wiki/Markup_language), which means that the text represents content, rather than being the content visually.
Other well-known markup languages include [LaTeX](https://en.wikipedia.org/wiki/LaTeX) and [Markdown](https://en.wikipedia.org/wiki/Markdown).

Therefore when writing content for your webpage, it is important to use an editor which accurately represents the contents of the file you are editing.
This is in contrast to software such as Microsoft Word, in which the content that you enter on the page is different than the underlying representation.
Some popular graphical text editors include [Atom](https://atom.io) and [Sublime Text](https://www.sublimetext.com).
If you do not want to install anything, [Notepad](https://www.microsoft.com/en-us/p/windows-notepad/9msmlrh6lzf3) is a built-in text editor on Windows.
Similarly, [TextEdit](https://support.apple.com/en-ca/guide/textedit/welcome/mac) is built-in on macOS.
For command-line editors, you could consider [Neovim](https://neovim.io) or [Emacs](https://www.gnu.org/software/emacs/).

One more subtlety is that not all text is the same.
Underneath, text is just binary data, so rules are required to convert the binary data into the textual representation: this process is known as [character encoding](https://en.wikipedia.org/wiki/Character_encoding).
The most common type of encoding used on webpages is [UTF-8](https://en.wikipedia.org/wiki/UTF-8), which is the transfer format for the [Unicode](https://en.wikipedia.org/wiki/Unicode) standard.
[ASCII](https://en.wikipedia.org/wiki/ASCII) is also a well-known encoding, but only supports a very restricted number of characters.
Certain older software, such as [TeX](https://en.wikipedia.org/wiki/TeX), defaults to files encoded in ASCII:{% inline_note() %}If you `\usepackage[utf8]{inputenc}`, you can use Unicode directly in the .tex file.{% end %} for example, to input directional quotation marks `“”` (which are [Left Double Quotation Mark](https://unicode-table.com/en/201C/) and [Right Double Quotation Mark](https://unicode-table.com/en/201D/) respectively), one would use <code>``</code> and `''`.
However, unless you are forced otherwise, you should try to write all your content in Unicode.

## Crash course in HTML and CSS
I'm going to assume you know some basics of HTML and CSS.
There are lots of tutorials online; here is a [nice one](https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/).
I'd recommend you read the articles on [HTML basics](https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/HTML_basics) and [CSS basics](https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/CSS_basics).

In this section, I'll give a streamlined description of setting up a basic functional webpage.
We are going to create 4 files:
```
.
├── 404.html
├── index.html
├── style.css
└── writing
    └── index.html
```

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
      <a href="writing/index.html">Writing</a>
      <a href="index.html">About</a>
    </nav>
    <article>
      <h1>Welcome to my webpage</h1>
      <p>This is some content!</p>
    </article>
  </body>
</html>
```
This isn't the most bare-bones possible HTML file, but it is a good _modern_ starting point for all HTML content on your site.
Here's an explanation of some of the tags:

- `<head>...</head>` and `<body>...</body>`: these are the two main sections of your HTML file.
  `<head>` contains the metadata, and `<body>` contains the content that will show up on your screen when you visit the webpage.
- `<meta charset="utf-8">`: declare that the content is encoded in [UTF-8](https://en.wikipedia.org/wiki/UTF-8).
- `<meta name="viewport" content="width=device-width">` ensures that, if this page is opened on a browser with a small screen, it will not be incredibly zoomed out.
  This is the bare minimum required so your page looks passable on a phone.
  You can read a bit about this [here](https://developer.mozilla.org/en-US/docs/Web/HTML/Viewport_meta_tag).
- `<title>`, `<meta name = "description" ...>`, `<meta name="author" ...>`: title, a short page description, and author.
- `<nav>...</nav>`: website navigation
- `<article>...</article>`: the 'content' of the page, i.e. your actual article or blog post but without the navigation, header, footer, etc.

Now if you open the file `index.html` you should get a page with two links at the top: **About**, and **Writing**.

Unfortunately the **Writing** link does nothing: we need to create that page.
Create a new directory called `writing` and in that directory create a file called `index.html`.
Then, fill it with pretty much the same contents as `index.html`, but replace the `<article>...</article>` with something slightly different, say
```
<article>
  <h1>Some things I've written</h1>
  <p>Nothing here yet...</p>
</article>
```
You can also change the title and description in this new page, as well.
Now, if you click on the navigation links, you have two working pages!

### Styling the page
We have a functional webpage, but it would be nice to make everything look a bit better.
Create a file `style.css`, and add the line
```
<link rel="stylesheet" type="text/css" href="style.css">
```
to the `<head>` of both HTML documents.
This tells the browser to look for a file `style.css` in the same directory as the file, which contains styling information.
While it is possible to define style inline in the HTML, this is bad practice since it is harder to maintain (as a general rule, HTML defines semantics, whereas CSS defines style).
Also, you should add some more content to the `<article>` section: perhaps a few more headers `<h2>...</h2>` and links `<a href="...some url...">my link</a>`.
This will make the styling changes more clear as you make them.

Let's begin with some basic styling.
First, add
```
body {
  margin: 0 auto;
  max-width: 700px;
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
h2 {
  margin-top: 1em;
  padding-top: 1em;
}
nav a {
  margin-left: 20px;
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
Now let's fix the font sizes:
```
header {
  margin: 0px;
  font-size: 23px;
}
article {
  font-size: 16px;
}
nav {
  font-size: 18px;
  letter-spacing: 1px;
}
h1 {
  font-size: 26px;
}
h2 {
  font-size: 23px;
}
```
Finally, let's add a bit of character by styling the links:
```
a {
  color: #ffa64d;
}
```
Our webpage looks a bit cleaner now!

### Grid layout
However, we need to address some more serious layout problems: currently, the navigation is way too small, and the header does not stand out at all.

To fix this, we are going to use a relatively new CSS technique known as [CSS Grid](https://developer.mozilla.org/en-US/docs/Web/CSS/grid){% inline_note() %}A nice reference for CSS Grid can be found <a href="https://css-tricks.com/snippets/css/complete-guide-grid/">here</a>.{% end %}.
Essentially, grid allows us to specify layout in a parent element, and then place the children inside this layout.

First, let's specify the general layout of our grid.
We want three sections: a header in the top left (for our title), a navigation bar in the top right, and then a main area containing all the content of the site.
Let's target the `<body>` element to set up this grid:
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
Let's break down what this is doing.

- `display: grid`: this element is specifying a grid layout for its children.
- `row-gap: 5px`: have some space between the rows
- `grid-template-columns: auto auto`: determine the width of the columns automatically
- `grid-template-rows: 60px auto`: set the first row (containing the header and navigation bar) to have height 60 pixels, and the second row to be sized automatically based on the content
- `grid-template-areas: ...`: assign names to the areas.
  We have `header` in the top left, `nav` in the top right, and `ct` everywhere else (spanning both columns).
  Note that the names can be whatever you would like (there is no special meaning assigned to using `header` and `nav`).

Now, let's assign our child elements to the areas in this grid, and do a bit of styling.
```
header {
  grid-area: header;
  justify-self: left;
  align-self: end;
}
nav {
  grid-area: nav;
  justify-self: right;
  align-self: end;

}
nav a {
  text-align: right;
}
article {
  grid-area: ct;
  border-top: 2px solid gray;
}
```
We want the header to be justified to the left and the navigation bar to be justified to the right.
Note that `align-self: end` means that, within the grid row, we want to be placed as late as possible.
This is important since the row has height 60 pixels, and without this argument, our header and navigation bar would be placed adjacent to the top of the screen!
In general, `align` refers to vertical placement and `justify` refers to horizontal placement.
Finally, we add a line above the `<article>` element with `border-top: 2px solid gray` to separate our header and navigation bar from the rest of the content.

### Responsive design
Now, our layout looks decent on a computer, but now we might have some problems on small screens!
The main problem is that if the screen is narrow, our header and navigation bar will start folding over itself.
To fix this, we can use [media queries](https://developer.mozilla.org/en-US/docs/Web/CSS/Media_Queries/Using_media_queries).
This is CSS which is applied only when the query is satisfied: in this situation, we want these rules when the screen is narrow (less than 430 pixels wide).

Here, we only change the styling a bit:

- place the header on top of the navigation bar by changing the grid layout in the body
- centre the header and navigation bar
- remove the asymmetric styling on the navigation links

This is done with the following CSS code.
```
@media screen and (max-width: 430px) {
  body {
    grid-template-columns: auto;
    grid-template-rows: minmax(40px, auto) minmax(30px, auto) auto auto;
    grid-template-areas:
    "header"
    "nav"
    "ct"
  }

  header, nav {
    text-align: center;
    justify-self: center;
  }

  nav a {
    margin: 0 10px;
  }
}
```
The `minmax(40px, auto)` means that we want to row to be at least 40 pixels tall, except that we should make it taller if the elements inside require it.
We also adjust the header and navigation bar to be nicely centred, since they are now placed on top of each other (rather than side by side).

Now, our webpage also looks respectable even when viewed on exceptionally tiny phone screens.

### Dealing with links
Throughout this article, the links have been written in the form `href="style.css"`.
This specifies a _relative link_: the file path is taken relative to the directory that the file in which the link sits.
When deploying the webpage to a server, you will want to write this in the form `href="/style.css"`, which will give a link to the root of your website.
This tells the browser to take whatever the base URL (for example {% verbose_url() %}https://example.rutar.org{% end %}) and append the link.
However, when browsing files on your device, the base URL is the root of your filesystem, i.e. `/`, so `/style.css` will (attempt to) link to the root of your filesystem directory, which is not what you want!

Moreover, there is a convention for linking directly to files HTML files: files with the name `index.html` are given special treatment.
Suppose your directory structure looks like the following:
```
.
├── index.html
└── writing
    └── index.html
```
Now, you can reference the file `index.html` with `href="/"` and the file `writing/index.html` with `href="/writing/"`.
This is the standard way to include files in your project repository.
To summarize, here are the changes we need to make (in all the HTML files):

- change `href="style.css"` to `href="/style.css"`
- change `href="index.html"` to `href="/"`
- change `href="writing.html"` to `href="/writing/"`

Our links will no longer work properly when browsing the files locally, but when we create host our webpage, the links will now work properly.
We also want to deal with the case where the user tries to browse to a link which does not exist.
For example, on this site, if you navigate to a URL like {% verbose_url() %}https://rutar.org/does-not-exist{% end %}, you will be shown a page explaining what happened.

For this to happen automatically, we simply need to create a file `404.html` at the root of our directory, with some content explaining that the page is missing.
The 404 is a [HTTP response status code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status), where the server tells the client that the page you are looking for is missing.
Often, the server will default to showing the contents of the `/404.html` file.

[Here](https://raw.githubusercontent.com/alexrutar/webpage-example/master/404.html) is an example of this file.
This file also has proper naming of links, as discussed above.

### Finishing up
You can view the complete website at {% verbose_url() %}https://example.rutar.org{% end %}.
The files themselves can be found [on GitHub](https://github.com/alexrutar/webpage-example).
You can ignore the additional files: those will be explained in later sections.

Here are some direct links to the files which we have prepared above:

- {% verbose_url(title="index.html") %}https://raw.githubusercontent.com/alexrutar/webpage-example/master/index.html{% end %}
- {% verbose_url(title="writing/index.html") %}https://raw.githubusercontent.com/alexrutar/webpage-example/master/writing/index.html{% end %}
- {% verbose_url(title="style.css") %}https://raw.githubusercontent.com/alexrutar/webpage-example/master/style.css{% end %}
- {% verbose_url(title="404.html") %}https://raw.githubusercontent.com/alexrutar/webpage-example/master/404.html{% end %}

In my opinion, the best way to learn more about HTML and CSS is to take a website which you like and use the **View Source** or **Inspect Element** functionality in your browser.
The [MDN Web Docs](https://developer.mozilla.org/en-US/) are an incredibly rich resource which contain almost everything you might want to know about web development.
Whenever I need to look anything up, that's where I start.

If your browser is Safari on macOS, you can enable some nice development features with the [Safari developer tools](https://support.apple.com/en-ca/guide/safari/sfri20948/mac) option.
For example, this allows you to emulate different browsers, and enter a responsive design mode which allows you to manually modify the screen size and view how your webpage will change.

Firefox also has similar functionality built in to the [Firefox developer tools](https://developer.mozilla.org/en-US/docs/Tools), and the Google Chrome browser in [Chrome DevTools](https://developer.chrome.com/docs/devtools/).

## Deployment with GitHub and Cloudflare Pages
Now that we have created our personal webpage, we want to make it publicly available!
In order to do this, we will use [GitHub](https://github.com) to host our files, and then integrate Cloudflare Pages with our GitHub account to take the hosted files and deploy them to our domain.

GitHub is a hosting provider for [git](https://git-scm.com), which is software for tracking and saving changes to a set of files.
In fact, I would recommend that you learn how to use git locally, and then integrate it with GitHub.
However, the tutorial for setting this up is much to involved for this article!
You can find some pointers to get started on the [git webpage](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control) and on [GitHub](https://docs.github.com/en/get-started/quickstart/git-and-github-learning-resources).

### Creating the repository on GitHub
First, you need to create a new repository.
I would recommend that you follow the instructions [here](https://docs.github.com/en/get-started/quickstart/hello-world#creating-a-repository).
Here are a couple notes:

1. You can name the repository anything you would like (you do not need to choose `hello-world`).
2. Optionally, you can choose the **Add README** option, which you can later modify to provide information on your webpage.
   This file will be used to display information on your repository.
3. You can also choose to either make your webpage public or private.
   A public repository means that anybody can view (but not edit) your GitHub repository, whereas only you – or anybody you give permission – will be able to see the repository if it is private.

Once you've finished creating the new repository, you need to add files that we created earlier!
To do this, click on the **Add File** option, beside the **Code** drop-down menu in green.

1. If you choose the **Upload files** option, the file will be placed directly into the folder.
   To upload files to a subfolder, you need to click on the subfolder first and then choose the **Add File** option.
   Somewhat inconveniently, this requires the folder to already exist.
2. If you choose the **Create new file** option, you can specify the filename directly and copy-paste the contents into the built-in browser.
   In order to put the file in a subfolder, simply provide a filename containing a backslash.
   For example, to add the HTML file for the **Writing** tab, enter the name **writing/index.html**.

Once you have added the file(s), click the **Commit new file** option at the bottom.
It is simplest to choose the default option (**Commit directly to the `...` branch**).

Once you've finished, the repository should look something like [this](https://github.com/alexrutar/webpage-example).

### Deploying on Cloudflare
To set up the webpage with Cloudflare Pages, we first need to tell Cloudflare about the repository hosting our files.
The best way to do this is to follow the instructions [in the Cloudflare Pages documentation](https://developers.cloudflare.com/pages/get-started#connecting-your-git-provider-to-pages).
Here are a couple notes:

1. The **Project name** that you choose will be used to create the default Cloudflare Pages domain: for example, I named my project `webpage-example` and my default Cloudflare-provided URL is {% verbose_url() %}https://webpage-example.pages.dev{% end %}.
2. Under the **Build command**, simply write `exit 0`.
   Leave the **Framework** option and the **Build output directory** as their default values.

Once you've finished and selected **Save and Deploy**, wait for the build to finish (this will take a few minutes, even though there is nothing to build!) and then your webpage will be publicly available!

### Going forward
Now, to make edits to your webpage or add new files, simply edit existing files or add new files to the GitHub repository.
Once the changes are committed to the repository, Cloudflare will automatically update your webpage!

## Further topics
### Custom domain setup
There are a few parts to setting up a custom domain.
First, you need to register a domain name, and then you need to set up [DNS](https://en.wikipedia.org/wiki/Domain_Name_System) to associate your domain name with the address where your webpage is hosted.

#### Domain Name Registration
[ICANN](https://www.icann.org/registrants) is the main body responsible for regulating domain name registration.
In terms of domain registrars, I would recommend one of the following:

- [Cloudflare Registrar](https://www.cloudflare.com/en-ca/products/registrar/)
- [AWS Route 53](https://aws.amazon.com/route53/)
- [Namecheap](https://www.namecheap.com)

I would definitely be careful with other hosts - certain popular domain registrars engage in [shady practices](https://news.ycombinator.com/item?id=24506303) such as registering domains that you look up on their site so that they can make you pay more money for them!
For simplicity, in this tutorial we will use Cloudflare.

TODO: write

#### Setting up DNS on Cloudflare
Once again, since our site is already hosted on Cloudflare, let's use Cloudflare for DNS as well.

#### Adding a record for our webpage
Finally, adding the record for our webpage is straightforward: navigate to the project configuration page and select the **Custom domains** tab.
Input your custom domain name and select **Continue**.
For a bit more detail, see the [documentation](https://developers.cloudflare.com/pages/get-started#adding-a-custom-domain).

Once you've done this, you might have to wait a couple minutes for the DNS to propagate (sometimes, you need to refresh your own WIFI connection) and then your site will be available at your domain!


### Creating favicons
A [favicon](https://en.wikipedia.org/wiki/Favicon) is a small image loaded by the browser and displayed on the website tab.
There is a lot of different advice on how to appropriately set favicons, and unfortunately a lot of it is very outdated.

These days, modern browsers support [SVG](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics) favicons and this format is easiest way to add a favicon to your webpage: it is lightweight and scales properly.
There are lots of tools available to create these images - I used [this site](https://formito.com/tools/favicon).
You can also just download an icon from a place like [font awesome](https://fontawesome.com/v5.15/icons?d=gallery&p=2&m=free) - there are a lot of options.
There's a [web-hosted implementation](https://jakearchibald.github.io/svgomg/) of the [svgo tool](https://github.com/svg/svgo) which is useful for compressing your SVG file.

To add the favicon to our webpage, first copy the icon file, say `icon.svg`, to the `static/` folder.
Then add the following line to the `<head>` of your base template.
```
<link rel="icon" href="/icon.svg" type="image/svg+xml">
```
This tells the browser that there's an icon located at `/icon.svg`, and that it's an SVG file.

If you wish to support more devices, I'd recommend that you read this [favicon article](https://evilmartians.com/chronicles/how-to-favicon-in-2021-six-files-that-fit-most-needs).
The next most important file to create would be a `favicon.ico` file: this will display the favicon even on outdated browsers.

### site security
- [Mozilla observatory](https://observatory.mozilla.org/analyze/rutar.org)
- Cloudflare `_headers` file
- [HSTS Preload](https://hstspreload.org)
- [GTMetrix](https://gtmetrix.com/analyze.html)

### HTTPS
- [read about why HTTPS](https://doesmysiteneedhttps.com/)
