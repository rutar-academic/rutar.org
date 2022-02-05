+++
title = "Setting Up a LaTeX Work Environment with Neovim and Fish Shell"
description = "This is a presentation of my LaTeX work environment which I use daily"
date = 2022-02-04
draft = true

[extra]

[taxonomies]
tags = ["vim", "shell"]
+++
In a [previous post](@/writing/from-vim-and-tmux-to-neovim.md), I talked about migrating to a [neovim](https://github.com/neovim/neovim) setup for my work environment.
I also recently started using [fish](https://fishshell.com/), which is an interesting alternative to the usual bash or zsh.
In this article, I will specifically discuss my setup when editing LaTeX documents.

## My work environment with vim and tmux
## NeoVim servers, communication
## Properly setting up neovim
- renaming vim to use /tmp/nvimsocket
## An example: automatic `lcd` on change directory in terminal
- each tab has a purpose and a :lcd
- `cd` vs `lcd`
- IDE emulation
## Hooking into shell (zsh / fish)
- https://vi.stackexchange.com/questions/21798/how-to-change-local-directory-of-terminal-buffer-whenever-its-shell-change-direc
- zsh hooks https://github.com/fish-shell/fish-shell/issues/583
- fish hooks
