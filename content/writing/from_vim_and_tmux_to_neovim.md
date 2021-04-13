+++
title = "From Vim and Tmux to Neovim"
description = "I discuss how and why I changed my work environment from a combination of vim and tmux to neovim."
date = 2021-04-14

[extra]

[taxonomies]
tags = ["vim", "shell"]
+++
I recently migrated from a vim and tmux work environment to one using only [neovim](https://neovim.io/).
In this article, I will discuss some of the issues I had with my old workflow, and why this transition resolved some of these problems.
I will not to go into much detail about my zsh and neovim setup; you can read about that [here](@/writing/setting_up_a_work_environment_with_zsh_and_neovim.md).

## My Work Enrivonment with vim and tmux
For reference, here is a crude approximation of my work environment with vim and tmux:

- Each project gets its own tmux session.
Within each session, have a dedicated window for performing a task (running a terminal, or vim, or some other tool).
- Allow session persistence with [tmux-ressurect](https://github.com/tmux-plugins/tmux-resurrect).
- Open new file edits in vim splits / buffers / tabs, and new terminals in tmux panes / windows.

Overall, this worked well, and I used this setup for a couple years.
However, over time, I accumulated some annoyances that were challenging to resolve.

## Disillusionment
My main struggle with using vim inside tmux is that there are often multiple ways to do the same thing.
For example, tmux lets you split the window vertically with `CTRL-b "` and vim lets you do this with `CTRL-w s` or `:vsp`.
And these splits are not interoperable.
Navigation commands are different, and often I found myself trying to `CTRL-w l` into a tmux split, which just doesn't work.
Moreover, you can't yank / paste between different tmux splits.
Other standard actions in vim (changing the directory with `:cd` or `:lcd`) have equivalences in tmux, but this requires entering verbose commands, or binding (and memorizing and using) new shortcuts.

Having to change my mindset from tmux mode to vim mode was a frequent source of friction in my workflow.

I also had some other more minor, but long-running, gripes with tmux.

1. The tmux-ressurect plugin is great, but it occasionally struggles to restart windows running an instance of vim.
Moreover, shutting down tmux sessions with vim instances active has a tendancy to create floating swap files.
2. I had many unresolved issues getting colours to show up properly inside a tmux session.
When colours work, everything is great.
But when colours don't work, life becomes hell trying to resolve this.
3. The additional layer of tmux abstraction eats a _whole extra line_ of your screen real estate.
4. I had minor situational input latency issues that were hard to diagnose.

There are likely ways to fix many of these problems listed above.
However, I like solutions with minimal complexity, and continually layering fixes above my existing workflow does not appeal to me.

## A solution, perhaps?
Many of the problems detailed in previous section can be easily fixed by simply not using tmux.
The only catch here is that I would lose two important features: convenient access to new interactive terminals, and session persistence.
It turns out that both of these issues can be solved using only neovim.

Most of what I will discuss in the next section will work in modern versions of vim as well (at least [vim 8.1](https://www.vim.org/vim-8.1-released.php)).
For simplicity, I will only discuss my solution using neovim.

### Running a terminal inside neovim
Running a terminal inside neovim is very easy: just run `:term` to convert the current split into a terminal.
Open a terminal in a new vertical split with `:vsp +term` (or any file other editing command).
Hit `i` to enter a special terminal edit mode, and return to normal mode `CTRL-\ CTRL-n` (all other keystrokes are passed through).

In order to open your standard shell, add a line like
```
set shell=zsh\ --login
```
to your `init.vim`.
To have an authentic terminal experience, it's also nice to turn off line numbers.
neovim provides an event `TermOpen` which we can use for this purpose:
```
autocmd TermOpen * setlocal nonumber norelativenumber
```
We now have a functional terminal running inside neovim.

There is one problem with this setup: if we open a file with `nvim` from inside a neovim terminal, we get a nested neovim instance running inside the terminal.
One solution to this problem is to use [neovim-remote](https://github.com/mhinz/neovim-remote).
With neovim-remote, we can send keystrokes to a running neovim instance from any terminal instance.
As a consequence of this, from within our `:term`, just run `nvr filename` and `filename` will be opened the terminal window, without nesting.
If you don't want to replace your current window, for example you can the file in a new vertical split using `nvr -O file`.

### Saved state and session management
neovim comes with a built-in utility for saving sessions: the `:mksession` command.
Called with an optional file argument (which defaults to placing a `Session.vim` file in the current `:pwd`), it generates a neovim source file at that filename which, when sourced, restores the state of the instance when `:mksession` was first called.
While `:mksession` works very well for can be somewhat awkward to use in practice.
However, with a small amount of work we can use it to robustly save the state of our vim instance, and restore it when needed.

The first trick is the easiest: just install Tim Pope's [vim-obsession](https://github.com/tpope/vim-obsession).
This plugin defines an `:Obsess` command, which is used in the same way as `:mksession`, but with some great quality of life features:

1. It automatically saves the session at every `BufEnter` event.
2. It maintains its own state within the session file, so any session you restore is automatically saved.

It does some other nice things, which you can read about on the vim-obsession page linked above.

In practice, using vim-obsession looks something like the following.
You open up a new workspace `nvim filename` and run `:Obsess session.vim` (or whatever filename you want).
Edit as normally, creating new splits or tabs liberally, and when you are finished, just `:wqa`.
Next time you are in the same directory and want to edit the files, restart the session with `nvim -S session.vim`.
Now, `:Obsess local_session.vim` is already running and we don't need to think about it at all.

For convenience, we can write a quick wrapper for `:Obsess` to save all our session files in a single location, and a utility to restore sessions.
Place the line
```
command -nargs=1 SSave Obsess $NVIM_SESSION_DIR/<args>.vim
```
somewhere in your `init.vim`, and the function
```
v() {
    local fname ultllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll
    if [ -n "$1" ]; then
        fname="$NVIM_SESSION_DIR/$1.vim"
        if [ ! -f "$fname" ]; then
            echo "Error: the session file '$1' does not exist!"
            return 1
        else
            nvim -S "$fname" ${@:2}
        fi
    fi
}
```
in your `.zshrc` (or similar).
You will also need to `export $NVIM_SESSION_DIR="/my/session/directory"` where `/my/session/path` is a directory in which you want the session files to be saved.

Now, when you want to create a new session, simply `:SSave project/name` to initialize the session file with name `project/name`.
Edit as usual, and `:wqa` to exit.
Then rejoin where you left off, just run `v project/name` from anywhere, and the state will be automatically saved as you edit.

As a warning, since `:Obsess` will overwrite existing session files, `:SSave` (if called with an existing `project/name`) will happily wipe out the saved state of an existing session!
You may want to modify the definition of `:SSave` to prevent this from happening.

If you want completion, add the function
``` 
v_session_list() {
    cd $NVIM_SESSION_DIR && find . -type f -name "*.vim" \
        | cut -c 3- | cut -d "." -f 1
}
```
to your `~/.zshrc` and create a file with name `_v` somewhere in your `$fpath` (or wherever completion files are saved in your personal shell) with content
```
#compdef v

_v() {
    if (( CURRENT == 2 )); then
        _alternative "files:sessions:(${(@f)$(v_session_list)})"
    fi
}
_v
```
Now, typing `v <TAB>` will offer up the acceptable possibilities for your session name.

## Concluding remarks and some challenges
This setup is conspiculously missing convenient instance persistence.
Every time you want to rejoin a session, you are running a lot of session code to restart the neovim instance.
This is quite fast, but it would be a lot better to place the neovim instance in the background, or temporarily suspend it to rejoin it again later.
Currently, I simply suspend my vim instance with `CTRL-z` and then restore with `fg`.
However, this is not a particularly nice solution and I have not yet spent the time figuring out how to do this properly.

However, so far, I am very happy with the way this setup works.
It remains to be seen if this setup will last longer than my previous one.