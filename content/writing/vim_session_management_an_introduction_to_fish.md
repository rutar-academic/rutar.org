+++
title = "Vim Session Management: An Introduction to Fish"
description = "An introduction to writing functions in fish, by example."
weight = 0
date = 2022-02-01

[extra]
toc = true

[taxonomies]
tags = ["cli", "fish"]
+++
[Fish shell](https://fishshell.com) is a user-friendly command line shell and scripting langauge.
However, the project is relatively new, so it can be somewhat challenging to find concise information on how to use the scripting language.

## Objectives
In this article, we will develop a basic session management tool for (Neo)Vim.
The intention of this tool is to be a wrapper around Tim Pope's [obsession.vim](https://github.com/tpope/vim-obsession) plugin, with the following features:

1. [Easy session initialization](#session-initialization-and-management) - list sessions and open them
2. [Active session management](#active-session-management) - we only want to allow a single instance of vim to be using a session file
3. [Autocompletions](#autocompletions) - get relevant results when you hit `TAB`

Perhaps you simply find the session management tool useful: you can find the program in the [Git repository](https://github.com/alexrutar/vs).
This implements all the features below, along with a couple extra useful commands, completions, and help messages.

### Pre-requisites
I will assume that you have the tools [fd](https://github.com/sharkdp/fd) and [fzf](https://github.com/junegunn/fzf) installed and accessible in your shell.
If you don't, you can simply omit the components that use `fzf`, and rewrite the parts using `fd` to use `find` instead.
I will also assume you know a bit about (Neo)Vim, including plugin installation.

## Session initialization and management
In this section, we will write the core functionality of our program: save and open session files.

First, let's create a global variable to represent where we want to save the session files.
```
set -x VS_SESSION_DIR "~/.local/share/vim/sessions"
```
in your `config.fish`, or wherever you prefer to define environment variables.
You can set the folder to be anything you want.
Now `exec fish` to load this variable.
To ensure that this variable is loaded, you can run
```
envs | grep ^VS_SESSION_DIR
```
and check that there is a match.
The command `env` prints out all currently defined environment variables - we just search for the line that starts with `VS_SESSION_DIR`.

### A wrapper for Obsession.vim
[Obsession.vim](https://github.com/tpope/vim-obsession) is itself a wrapper around the vim command `:mksession`, which creates a session file and saves the current state of vim (e.g. tabs, windows, layout, etc.) to that file.
If you have a session file `session.vim`, you can restart it with `vim -S session.vim`.
Install this plugin in your `vimrc` and also add the function definition
```
command -nargs=1 VSave Obsess $VS_SESSION_DIR/<args>.vim
```
This defines a command `:VSave`, which takes exactly one argument which is the name of the session file (with no extension).
To begin a new saved session, run `:VSave my/session` from an active vim instance.
To terminate, run `qa`: note that closing files individually will modify the session file so those files will remain closed on restart.

### Starting up existing sessions
Fish functions are defined in the folder `~/.config/fish/functions` and corresponding completions in `~/.config/fish/completions`.
Let's write the command to start up new sessions, which we will invoke with `vs`.
We want to accept the session name as an argument, and then check if the session file exists: if it does, open it; if not, terminate with a nice error message.
In the file `~/.config/fish/functions/vs.fish`, we define a function as follows:
```
function vs --argument session_name
    set -l sessionfile $VS_SESSION_DIR/session_name.vim
    if test -f $sessionfile
        vim -S $sessionfile
    else
        echo "Could not find session '$session_name'" >&2
        return 1
    end
end
```
To invoke, just run `vs <session name>`, and the corresponding session will be started!

The `--argument session_name` automatically assigns the first argument passed to `vs` to the variable `session_name`.
Note that the variable will be empty if there are no arguments passed to `vs`.
Any other arguments are simply ignored.
In shell scripting languages, conditionals often execute based on the return code of a command.
In this case, the command `test -f` returns 0 if `$sessionfile` exists, and returns something else otherwise.
We redirect the output of `echo` to STDERR with `>&2`, and then return with the default error code 1.

Note that you can define multiple functions in a single file `myfunc.fish`, but fish only knows to load those functions on request if there is a matching filename.
You should only define helper functions for the main function in the file, since they will not be loaded until the main function is called.

You can also edit functions in the current interactive shell with `funced <function name>`, and save the functions to the directory with `funcsave <function name>`.
However, doing this will remove any helper functions you have defined in the file!
This is also an easy way to introspect fish functions which you may have not defined yourself.

If you edit a function file, sometimes you need to reload your shell for proper execution.
The easiest way to do this is to `exec fish`.

### A basic subcommand: session listing
For convenience, it would also be nice to be able to get a list of the existing session names.
This utility will also be necessary later, when we provide autocompletion.
Now, since we want multiple behaviours, we will invoke the desired behaviour with two subcommands: we will invoke the previous function with `open`, and the new listing function with `list`.
First, we define a helper function to list sessions.
Using `fd`, we can quickly get a list of candidate files:
```
fd -e vim --base-directory $VS_SESSION_DIR
```
However, we only want the name of the session and not the extension `.vim`.
The easiest way to do this is to use `--exec echo {.}`: `{.}` is replaced with the filename with no extension.
This also handles the case where the filename has multiple periods, unlike something more direct such as `cut -d "." -f 1`.
We also want to sort the output, since `fd` is multithreaded by default when called with `--exec` and the order can change each time (which could be confusing).

Wrapping this in a function, we get
```
function __vs_list_sessions
    fd -e vim --base-directory $VS_SESSION_DIR --exec echo {.} | sort
end
```
We can add this as a subcommand to our original function:
```
function vs --argument command session_name
    switch $command
        case open
            set -l sessionfile $VS_SESSION_DIR/session_name.vim
            if test -f $sessionfile
                vim -S $sessionfile
            else
                echo "Could not find session '$session_name'" >&2
                return 1
            end
        case list
            __vs_list_sessions
    end
end
```
Now, open session files with `vs open session/name` and list possibilities with `vs list`.

### Fancy session selection with fzf
For convenience, let's also write an interactive file chooser using [fzf](https://github.com/junegunn/fzf)
This command reads input from STDIN and opens up an interactive browser which allows selection.
Upon choosing an option, the corresponding line is sent to STDOUT.
This variable is captured using fish parameter expansion `(...)` and saved in the variable `fzf_session`.
Note that if `fzf` is terminated early using `CTRL-C`, the variable `$fzf_session` will not be saved, so we also need to check that it is non-empty.

Add the following at the beginning of the indentation block directly below `case open`:
```
if not test -n "$session_name"
    set -l fzf_session (__v_list_sessions | fzf --height 40% --border --tac)
    if test -n "$fzf_session"
        set session_name $fzf_session
    else
        return 0
    end
end
```
Essentially, when `vs open` is called with no session name, an interactive prompt opens and allows you to search the available sessions.

In fish, quotes are usually not required since variables are passed 'as atoms' rather than being expanded and separated on whitespace (as is the case with bash).
One of the few exceptions to this rule is `test -n "$var"`, which checks that `var` is defined and non-empty.
In this situation, you must always quote the variable since if var is not defined, then `$var` will expand to an argument list of length 0, essentially calling `test -n` instead of the desired `test -n ""`.

## Active session management
Now let's add active session management.
If one shell instance has a session file open, we want to prevent another instance from opening up the same session file: multiple writes to the session file could corrupt the file!
We will achieve this with [file locking](https://en.wikipedia.org/wiki/File_locking).
However, a bit of care needs to be taken: we need to handle termination of the script while it is running.
The easiest way to do this to use [event handlers](https://fishshell.com/docs/current/cmds/function.html).

When a function is created, it can be registered as an event handler for certain events.
We care about three events: when the function receives the signal `SIGINT` or `SIGHUM`, which indicates interruption of the script, or when the shell itself terminates.

### Basic event handler example
Consider the following function:
```
function example
    function __example_cleanup --on-signal INT --on-signal HUP --on-event fish_exit
        functions -e __example_cleanup
        echo "Cleaning up!"
    end
    read -p 'echo "Press ENTER to continue "'
    echo "Done!"
    __example_cleanup
end
```
If you run the script normally, following the prompt, the function simply prints
```
$ example
Press ENTER to continue <ENTER>
Done!
Cleaning up!
```
to your terminal.
However, suppose instead of pressing `ENTER`, you hit `CTRL-C` to terminate.
Then the `__example_cleanup` event runs immediately, and the function will print
```
$ example
Press ENTER to continue <CTRL-C>
Cleaning up!
```
Even though the function never completed, the cleanup function still fires.

The handler `--on-event fish_exit` also catches the case where you, say, close the entire terminal window while the function is running.
Note that we must delete the function `__example_cleanup` when we execute it, with `functions -e`.
Otherwise, `__example_cleanup` will continue to live in our interactive shell and will fire even if we run `CTRL-C` during the execution of a different program.

### Incorporating this with file locking
Our idea is now the following: when we first start up our session, we check for the existence of lock files.
If one does not exist, create it, and start up the session; otherwise, terminate with an error,
For convenience, since the session files are saved as `<session name>.vim`, let's save the lock files as `<session name>.lock`.
In order to avoid race conditions, we can create the lock file and test its existence simultaneously using `mkdir`:
```
if mkdir <session name>.lock &> /dev/null
    echo "Normal execution..."
    return 0
else
    echo "Lock file exists!" >&2
    return 1
end
```
This works since `mkdir` returns error code 1 if the directory it is trying to create already exists.
We also supress the `mkdir` error message, since we want to send a more meaningful one to the user ourselves.

We also need to clean up the lockfile on exist using the event handler from the previous section.
All together, our code now looks like this
```
if test -f "$sessionfile"
    function __vs_cleanup \
            --inherit-variable lockfile \
            --on-signal INT --on-signal HUP --on-event fish_exit
        functions -e __vs_cleanup
        rmdir $lockfile
    end

    if mkdir $lockfile &> /dev/null
        vim -S $sessionfile
        __vs_cleanup
    else
        echo "Session '$vs_fname' already running!" >&2
        return 1
    end
else
...
```
In principle, we might have to worry about multiple instances of the same event handler `__vs_cleanup`.
However, as of the time of writing this article, fish [does not support background functions](https://github.com/fish-shell/fish-shell/issues/238), so we only need to worry about our function running in multiple shells, in which case we do not need have this issue.

### A note on trap
Fish comes with a function `trap`, which is just a wrapper around the event handler method explained above.
At its core, the [implementation of trap](https://github.com/fish-shell/fish-shell/blob/master/share/functions/trap.fish) converts `EXIT` into `--on-event fish_exit` and all other signals into `--on-signal <signal name>`.
You can call `trap` directly with the cleanup function (with no handlers attached), like
```
trap __example_cleanup INT HUP EXIT
```
Note that, in this situation, the event handlers are not automatically deleted.
To do this, you need to run
```
trap - INT HUP EXIT
```
to reset the traps.

To debug issues with handlers persisting longer than you expect, you can get a list of all active handlers with
```
functions --handlers
```
## Finishing up
### Starting new sessions
It would also be nice to start new sessions with a terminal in the given directory.
We can tell vim to execute some commands using the `+<command>` syntax: such arguments passed to vim will be executed in order as the vim session is started.
For example, if you run
```
vim +term
```
you will get a vim terminal pane in the current directory.
Since we already wrote a function `VSave` earlier, it's a simple matter to call this function as well:
```
vim "+silent VSave <session_name>" +term
```
The `silent` command executes the next command without printing anything into the vim pane.
Now let's wrap this in a command `init`, and do a quick check that there is not an existing session with the provided name.
```
case init
    set -l sessionfile $NVS_SESSION_DIR/$session_name.vim
    if test -f $sessionfile
        echo "Cannot overwrite existing session '$session_name'" >&2
        return 1
    else
        (mkdir -p (dirname $sessionfile)) && vim "+silent VSave $session_name" +term
    end
```
Now, running `vs init <session_name>` will create a new session with name `<session_name>` and start out with a terminal in the directory where the command was called.

### The entire function
It remains to add a case where an invalid command is given, and to print out a short error message.
After doing this, our file `v.fish` now has the following contents:
```
function vs --argument command session_name new_session_name
    function __v_list_sessions
        fd -e vim --base-directory $VS_SESSION_DIR --exec echo {.} | sort
    end
    set -q VS_SESSION_DIR; or set -l VS_SESSION_DIR "~/.local/share/nvim/sessions"
    switch $command
        case open
            if not test -n "$session_name"
                set -l fzf_session (__vs_list_sessions | fzf --height 40% --border --tac)
                if test -n "$fzf_session"
                    set session_name $fzf_session
                else
                    return 0
                end
            end

            set -l sessionfile $VS_SESSION_DIR/$session_name.vim
            set -l lockfile $VS_SESSION_DIR/$session_name.lock

            if test -f "$sessionfile"
                function __vs_cleanup --inherit-variable lockfile \
                    --on-signal INT --on-signal HUP --on-event fish_exit
                    functions -e __vs_cleanup
                    rmdir $lockfile
                end

                if mkdir $lockfile &> /dev/null
                    vim -S $sessionfile
                    __vs_cleanup
                else
                    echo "Session '$session_name' already running!" >&2
                    return 1
                end
            else
                echo "Could not find session '$session_name'" >&2
                return 1
            end

        case list
            __vs_list_sessions

        case init
            set -l sessionfile $VS_SESSION_DIR/$session_name.vim
            if test -f $sessionfile
                echo "Cannot overwrite existing session '$session_name'" >&2
                return 1
            else
                mkdir -p (dirname $sessionfile) && vim "+silent VSave $session_name" +term
            end

        case '*'
            echo "Invalid command option '$argv[1]'" >&2
            return 1
    end
end
```
Here are some other feature ideas:

- custom `rename` and `delete` commands
- nicer file listing with `tree` (hint: use `tree --fromfile .` to format input from STDIN, and `isatty` to only format when the output is a terminal)
- add some nice help messages

### Autocompletions
Finally, it would be nice to have some autocompletions for our script.
Completion files are stored in a file with the same name as the function file, except in the `~/.config/fish/completions` directory.

We want basic descriptions for the commands when we hit `TAB`, and we also want autocompletion for the session name when we call `vs open`.
Fish completion files are also just regular lists of functions, except they are loaded when autocompletion for a certain function is requested.
You can read the fish [docs about completions](https://fishshell.com/docs/current/completions.html) if you would like.

We begin by disabling file completion on the base command, which is enabled by default.
This is done with the command
```
complete -f -c vs
```
This way, when we hit tab, we are not suggested offered files in the current directory in the completion list.
Now, we need to add our subcommands.
This is done as follows: to add the completion option `open`, we use
```
complete -c vs -a open -d 'Open the session file'
```
However, this has a problem since now fish will suggest `open` as a valid argument at any time, when it should only be valid at the beginning.
In order to fix this, we first introduce a list of all our valid command names with
```
set -l vs_subcommands open list
```
and then use the `-n` flag for `complete` to only complete in the case that we have not yet seen any subcommands.
We can also include an option for `vs list`.
```
complete -c vs -a open \
    -n "not __fish_seen_subcommand_from $vs_subcommands" \
    -d 'Open the session file'
complete -c vs -a list \
    -n "not __fish_seen_subcommand_from $vs_subcommands" \
    -d 'List available session files'
complete -c vs -a init \
    -n "not __fish_seen_subcommand_from $vs_subcommands" \
    -d 'Start up a new session'
```
Finally, when we have seen the subcommand `vs open`, we want to provide the valid list of options.
Here, the `vs list` command comes in handy:
```
complete -f -c vs -a "(vs list)" \
    -n "__fish_seen_subcommand_from open" -a "(vs list)"
```
As a whole, the contents of the completion file can be found [in the Git repository](https://github.com/alexrutar/vs/blob/master/completions/v.fish).
As a whole, the completion file `~/.config/fish/completions/vs.fish` looks like
```
set -l vs_subcommands init list open
complete -f -c vs
complete -c vs -a open \
    -n "not __fish_seen_subcommand_from $vs_subcommands" \
    -d 'Open the session file'
complete -c vs -a list \
    -n "not __fish_seen_subcommand_from $vs_subcommands" \
    -d 'List available session files'
complete -c vs -a init \
    -n "not __fish_seen_subcommand_from $vs_subcommands" \
    -d 'Start up a new session'
complete -c vs -a "(vs list)" \
    -n "__fish_seen_subcommand_from open" -a "(vs list)"
```
Now hitting `vs <TAB>` prompts with two options: `open`, or `list`, and hitting `vs open <TAB>` prompts with the possible session names.
