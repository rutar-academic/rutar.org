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
In this article, I will discuss some options for personal research site automation.
Since I primarily use [GitHub](https://github.com), this article will focus on the implementation details offered through their platforms.
However, there are many other providers which offer the same functionality described here: part of the goal of this article is to highlight some of the tools which exist, and what you might hope should be possible.

## Setup and preliminaries
I will assume that your personal website, and each project (such as a directory containing LaTeX files for a paper, or notes for a course) has its own repository.
Throughout this article, I will refer to the personal website repository as `owner/website-repo` and the project repository as `owner/project-repo`, and that they are hosted on GitHub.

I will assume that the structure of your website repository `owner/website-repo` contains a top-level directory `public-html` containing the public HTML files, as well as (possibly) other files.
Similarly, I will assume that the project repository `owner/project-repo` consists of a primary top-level LaTeX file `main.tex`, along with any other auxiliary files.
You can find an example project repository TODO: hosted here.


### Preliminaries on GitHub Actions
In practice, everything in this article could be implemented directly on your computer.
However, for services which you want to run frequently, it is often good to have the code execute on a server.
This has many benefits:

- The code can be written to run automatically under certain conditions without monitoring
- You do not use local resources
- You do not need to wait for things to execute
- You decrease your own personal workload since you do not need to do anything manually: everything just happens directly

Caveats:

- need to do more checks (e.g. pre-commit)
- need to check intermediate steps so things do not get badly broken (e.g. malformed website push)
- need to understand how to recover from these situations if things go wrong



One reasonable option, especially if you already have the code for your website stored in a GitHub repository, is to use [GitHub Actions](https://docs.github.com/en/actions).

The [GitHub Actions Documentation](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions) is a good place to start.
Here, I will explain how one might implement the above code inside a basic website repository.

### Pre-requisites and existing setup

## Generating release files in paper repositories
### Workflow contents
As discussed earlier, we put workflow files in the `.github/workflows` directory.
The immediate step is to create a file `.github/workflows/build.yml` with contents
```
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
    - cron: '30 10 * * *'
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
