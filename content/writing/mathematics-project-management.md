+++
title = "Mathematics Project Management"
description = "Some ideas on managing a large number of mathematics projects."
weight = 0
date = 2023-05-28
draft = true

[extra]
toc = true

[taxonomies]
tags = ["latex", "math"]
+++

- Include a section explaining the tool sources in detail, installation, and references.


1. Using `vs`.
2. Using `mbib`.
3. Using `copier` [https://copier.readthedocs.io/en/stable/](https://copier.readthedocs.io/en/stable/)
4. [https://pre-commit.com/](https://pre-commit.com/)
5. Using `git`, automatic compilation scripts, tags
6. Writing templates


# Miscellaneous scripts

## Searching for and opening papers
```fish
function pa --description 'Search papers directory using fzf'
    if count $argv > /dev/null
        set --function captured (mbib list | fzf --query $argv | cut -d " " -f 1)
    else
        set --function captured (mbib list | fzf | cut -d " " -f 1)
    end
    mbib file open $captured
end
```
