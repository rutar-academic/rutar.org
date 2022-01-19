+++
title = "Previewing a Development Branch on Cloudflare Pages"
description = "How to set up previews with custom build commands on Cloudflare Pages."
date = 2022-01-19

[extra]

[taxonomies]
tags = ["vim", "shell"]
+++
In this article, I assume that your repository is hosted on [GitHub](https://github.com), and the site is hosted on [Cloudflare pages](https://pages.cloudflare.com/).
I'm sure other providers will work, with similar instructions.

## Creating the development branch
First, create a new branch "development" (or any name you would like):
```
git pull
git branch development
```
Now to add draft changes, first
```
git switch development
```
then perform the changes you want and commit them. To include those changes in your main branch,
```
git switch main
git merge development
git push
```
Now, we just need to push the "development" branch to our GitHub repository.
```
git push origin development
```
Cloudflare will automatically build changes to your development branch, which you can preview at the url `development.<project-name>.pages.dev`.

## Customizing the build command
However, it is often the case that you want the build command for your development branch to be different than the build command for your main branch.
For example, if you use [Zola](https://getzola.org) for templating, you would build the main branch with
```
zola build
```
whereas you might build the development branch with
```
zola build --drafts
```
Moreover, when using Zola, the site url is automatically set based on the key `base_url` in your `config.toml`.
This works for the main branch, but our development branch has a different repository name, which will cause our internal links to be broken.

Conveniently, Cloudflare Pages defines an environment variable `$CF_PAGES_BRANCH`, which is the name of the branch currently being built.
We can use this variable to write a new build command with better behaviour.
```
if [ "$CF_PAGES_BRANCH" = "main" ]; then zola build; else zola build -u "https://$CF_PAGES_BRANCH.<project-name>.pages.dev" --drafts; fi
```
If the branch is your main branch, then just run `zola build`.
Otherwise, the preview URL will be `https://development.<project-name>.pages.dev`, which we manually specify with the `-u` option.
And we would also like to include draft articles in the preview as well.
If we decide to add more branches, the same non-main build command will work for any branch we add.

Now, whenever you push commits on your development branch to GitHub, you can visit a preview of the build at `https://development.<project-name>.pages.dev`.
