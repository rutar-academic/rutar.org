+++
title = "An Introduction to Webpage Templating"
description = "How to use template processors to simply static webpage development."
weight = 0
date = 2022-02-05
draft = true

[extra]
toc = true

[taxonomies]
tags = ["web", "css", "deployment"]
+++
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

