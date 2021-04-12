+++
title = "From Vim and Tmux to NeoVim"
description = "Fill in a description."
weight = 0

[extra]

[taxonomies]
tags = ["vim"]
+++
## Emulating a Terminal Emulator

## Problems and conceptual annoyances
- tmux tabs vs. vim tabs? vim tabs already do the job
- cannot easily communicate between tmux tabs (this seems to be possible with neovim for yanking etc. [see here](https://github.com/daplay/tmux_nvr))
- but it is still weird to try to navigate around windows (is it CTRL-b arrowkey, CTRL-W hjkl?)
- colours? I had tons of issues with getting colours to work on tmux + alacritty
- [weird copy behaviour](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard)

## Emulating 
- quick session initialization and saving
- tmux resurrect (vim sessions is a first class version of this)


## Some IDE like features
- searching with fzf

# neovim 'killer feature'
- easy access to terminal instances
- use nvr (neovim-remote)
