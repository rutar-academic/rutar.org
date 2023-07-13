+++
title = "Personal Site Automation"
description = "Basic automation of site hosting."
weight = 0
date = 2023-02-23
draft = true

[extra]
toc = false

[taxonomies]
tags = ["web", "deployment", "github"]
+++
In this article, I will discuss some options for hosting and automating personal websites.
Since I primarily use [GitHub](https://github.com), this article will focus on the implementation details offered through their platform.
However, there are many other providers which offer the same functionality described here: part of the goal of this article is to highlight some of the tools which exist, and what you might hope should be possible.
Of course, this article comes with the natural caveat that the details in this document are highly opinionated may need modification for your particular setup.

## Preliminaries and setup
### Using a deployment server
In practice, everything in this article could be implemented to run directly on your computer.
However, for services which you want to run frequently, it is often useful to have the code execute on a server.
This has many benefits:

- The code can run automatically under certain conditions, without being sensitive to the status of your local device (e.g. whether it is connected to the internet, or whether it is turned on or not)
- You do not need to dedicate any resources while using your device
- You decrease your own personal workload since you do not need to do anything manually: everything just happens directly

However, there are of course a number of caveats:

- You need to do more checks: for instance, you probably need a well-designed [pre-commit](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) to catch errors before you deploy them
- You need to check intermediate steps so things do not get badly broken (for instance, the build stage fails and you push a malformed webpage to a server)
- You need to understand how to recover from these situations if things go wrong

One reasonable option, and the option that will be used in this article, is to use [GitHub Actions](https://docs.github.com/en/actions).
This option is particularly convenient if your git repositories are already hosted on GitHub.
For general reference, the [GitHub Actions Documentation](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions) is a good place to start.
However, I will try to include most of the details concerning the usage of this platform from within this article.

The main drawback of using GitHub Actions is that you do not control your own instances and are dependent on an external framework that may cease to exist or change form to something less usable.
It is certainly possible to host this on your own server, but the details of doing this are well beyond the scope of this article!

### Setup
I will assume that your personal website, and each project (such as a directory containing LaTeX files for a paper, or notes for a course) has its own repository.
Throughout this article, I will refer to the personal website repository as `owner/website-repo` and the project repository as `owner/project-repo`, and that they are hosted on GitHub.

I will also assume that the structure of your website repository `owner/website-repo` contains a top-level directory `public-html` containing the public HTML files, as well as (possibly) other files.
Similarly, I will assume that the project repository `owner/project-repo` consists of a primary top-level LaTeX file `main.tex`, along with any other auxiliary files.
You can find an example project repository TODO: hosted here.

### Outline
Our general approach consists of two steps.

1. Inside each `owner/project-repo`, automatically compile the document into a PDF and save that PDF somewhere programmatically accessible.
   This is detailed in the [Generating release files](generating-release-files-in-project-repositories) section.
2. Inside the `owner/website-repo`, retrieve the compiled PDFs from the various project repositories, add them to the files in your website, and then copy to your server.


## Generating release files in project repositories
### Workflow contents
As discussed earlier, we put workflow files in the `.github/workflows` directory.
The immediate step is to create a file `.github/workflows/build.yaml` with contents
```yaml
name: Build LaTeX document
on:
  push:
    tags:
      - "v*"
jobs:
  build-latex:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Compile LaTeX Document
        uses: xu-cheng/latex-action@v2
        with:
          root_file: "main.tex"
          post_compile: mv "main.pdf" "${{ github.event.repository.name }}.pdf"
      - name: Release
        uses: softprops/action-gh-release@v1
        with:
          files: "${{ github.event.repository.name }}.pdf"
```
Your project repository should now look like
```
project-repo
├── main.tex
├── .github
⋮   └── workflows
        └── build.yml
```

### Description of components
Let's break down what this workflow is doing.
1. `name: ...` is specifying the name of this job, which you can choose to be anything you would like.
2. `on: ...` describes when this job should run.
   The specification
   ```
   on:
     push:
       tags:
         - "v*"
   ````
   says that this action should run every time there is a push which contains a tag matching the pattern `v*`.
3. `jobs: ...` is the header which describes what should be run.
   `build-latex` is simply a convenient name for the current job (in principle, you can have multiple jobs if necessary).
   We declare that this job should run on a server with the operating system specified by `ubuntu-latest`, and the job consists of three `steps`.
4. First, we need to checkout the repository with
   ```
   - name: Checkout
     uses: actions/checkout@v3
   ```
   Since the server begins in a blank state, we first need to load all the code from the repository.
   The `Checkout` action, when specified with no options, defaults to loading all of the contents of the current branch where the workflow is called from.
4. Next, we compile the LaTeX document `main.tex` and, after it is finished compiling, we rename the file to the variable.
   ```
   - name: Compile LaTeX Document
     uses: xu-cheng/latex-action@v2
     with:
       root_file: "main.tex"
       post_compile: mv "main.pdf" "${{ github.event.repository.name }}.pdf"
   ```
   Here, the target file name uses `${{ github.event.repository.name }}` which substitutes the current value of `github.event.repository.name`, which our case is just `project-repo`.
5. Finally, we create a release from the PDF file we just build.
   ```
   - name: Release
     uses: softprops/action-gh-release@v1
     with:
       files: "${{ github.event.repository.name }}.pdf"
   ```

### Using the workflow
Let's comment a bit more on the activation of the workflow described in 2.

[Git Tags] TODO: ref are simply named pointers to commits, which you specify yourself in your git repository.
For example, to make a tagged commit which matches the above specification, you might
```
git commit -am "<commit message>"
git tag v1.0 -m "<tag message>
git push --follow-tags
```
Note that it is important that the tag contains content, so that it can be pushed to the server.
TODO: lightweight, ...
Moreover, the `--follow-tags` option automatically pushes all tags ...
It is also possible to push tags manually with `git push origin v1.0`.

After you have pushed a tagged version that compiles without errors and the workflow runs, you will be able to find a PDF at the address `https://github.com/owner/project-repo/project-repo.pdf`.
If your repository is public, anybody can access this file, but if your repository is private, access to this file will be restricted.

## Retrieving release files
Now that we have build our PDF `project-repo.pdf`, we would like to automatically incorporate this file into a personal website or other repository.
Since this file is available at a URL, in theory, we could simply download this file directly using a tool like [curl] TODO: link.
However, if your project repository is private, the request needs to be authenticated.

It turns out that a convenient way to access this functionality is to use the [GitHub CLI](https://cli.github.com/).
The `gh` CLI tool gives a convenient abstraction layer over the [GitHub API](https://docs.github.com/en/rest?apiVersion=2022-11-28).
Moreover, with proper setup, `gh` can be authenticated to access private repositories that you own.

I will assume that your site is hosted on Cloudflare, since this is what I have setup.

In this setup, the build happens according to the cron, i.e. every day at 10:30am UTC.
You can also use a different activation, (TODO ref actions on), multiple are allowed, maybe mention API thing

### Rsync
```
rsync -avz --delete source target
```

### Publish
Create a file `.github/actions/publish.yml` with the contents
```
name: Automate Site Build

on:
  schedule:
    - cron: '30 10 * * *'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Download PDFs
        run: gh release download --repo username/repo --pattern '*.pdf' --dir pdf_directory/ --clobber
        env:
          GITHUB_TOKEN: ${{ secrets.GH_API_TOKEN }}
      - name: Publish
        uses: cloudflare/wrangler-action@2.0.0
        with:
          command: pages publish public-html --project-name=my-project
          apiToken: ${{ secrets.CF_API_TOKEN }}
```
Name
```
name: Automate Site Build
```
When to run
```
on:
  schedule:
    - cron: '15 08 * * *'
```
Main jobs
```
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
```
Main jobs
```
      - name: Checkout
        uses: actions/checkout@v3
      - name: Download PDFs
        run: gh release download --repo username/repo --pattern '*.pdf' --dir pdf_directory/ --clobber
        env:
          GITHUB_TOKEN: ${{ secrets.GH_API_TOKEN }}
      - name: Publish
        uses: cloudflare/wrangler-action@2.0.0
        with:
          command: pages publish public --project-name=my-project
          apiToken: ${{ secrets.CF_API_TOKEN }}
```
