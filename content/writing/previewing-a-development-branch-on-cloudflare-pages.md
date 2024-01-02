+++
title = "Previewing a Development Branch on Cloudflare Pages"
description = "How to set up previews with custom build commands on Cloudflare Pages."
date = 2022-01-19

[extra]

[taxonomies]
tags = ["git", "deployment"]
+++
In this article, I assume that your repository is hosted on [GitHub](https://github.com), and the site is hosted on [Cloudflare pages](https://pages.cloudflare.com/).
I'm sure other providers will work, with similar instructions.

## Creating the development branch
First, create a new branch **development** (or any name you would like):
<pre><code><kbd>git pull</kbd>
<kbd>git branch development</kbd>
</code></pre>
Now to add draft changes, first
{{ cli(command="git switch development") }}
then perform the changes you want and commit them. To include those changes in your main branch,
<pre><code><kbd>git switch main</kbd>
<kbd>git merge development</kbd>
<kbd>git push</kbd>
</code></pre>
Now, we just need to push the **development** branch to our GitHub repository.
{{ cli(command="git push origin development") }}
Cloudflare will automatically build changes to your development branch, which you can preview at the URL `development.<project-name>.pages.dev`.

## Customizing the build command
It is often the case that you want the build command for your development branch to be different than the build command for your main branch.
For example, if you use [Zola](https://getzola.org) for templating, you might build the main branch with
{{ cli(command="zola build") }}
whereas you might build the development branch with
{{ cli(command="zola build --drafts") }}
Moreover, when using Zola, the site URL is automatically set based on the key `base_url` in your `config.toml`.
This works for the main branch, but our development branch has a different URL, which will cause non-relative internal links to be broken.

Conveniently, Cloudflare Pages defines an environment variable `$CF_PAGES_BRANCH`, which is the name of the branch currently being built.
We can use this variable to write a new build command with better behaviour:
```sh
if [ "$CF_PAGES_BRANCH" = "main" ]; then zola build; else zola build -u "https://$CF_PAGES_BRANCH.<project-name>.pages.dev" --drafts; fi
```
If the branch is your main branch, then just run `zola build`.
Otherwise, the preview URL will be `https://development.<project-name>.pages.dev`, which we manually specify with the `-u` option.
And we also include draft articles in the preview as well, with the `--drafts` option.
If we decide to add more branches, the same non-main build command will work for any branch we add.

Now, whenever you push commits on your development branch to GitHub, you can visit a preview of the build at `https://development.<project-name>.pages.dev`.
