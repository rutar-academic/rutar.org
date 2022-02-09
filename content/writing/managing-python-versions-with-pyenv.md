+++
title = "Managing Python Versions with Pyenv"
description = "This is a short explanation of a useful tool for creating and managing Python versions."
weight = 0
date = 2022-01-20

[extra]

[taxonomies]
tags = ["cli", "python"]
+++
The [pyenv](https://github.com/pyenv/pyenv) command line utility is convenient tool for managing python versions.

## Installation
It's best to follow the above link for general installation instructions.
Otherwise, I will assume you are using macOS with Fish Shell.

First install `pyenv` and `pyenv-virtualenv` with brew:
{{ cli(command="brew install pyenv pyenv-virtualenv") }}
You also want to add some lines to your `config.fish`:
```
set -Ux PYENV_ROOT "$HOME"/.pyenv
status is-login; and pyenv init --path | source
status is-interactive; and pyenv init - | source
status is-interactive; and pyenv virtualenv-init - | source
alias brew="env PATH=(string replace (pyenv root)/shims '' \"\$PATH\") brew"
```
You can set `PYENV_ROOT` to be any location you would like.
The remaining commands are used to initialize `pyenv` and add the corresponding python versions to your `PATH`.

## Startup
The first thing to do is to set your preferred global python version:
{{ cli(command="pyenv global 2.7.18 3.10.1") }}
sets the `python2` version to `2.7.18` and the `python3` version to `3.10.1`.
The global version is useful for user-wide modules and tools you might want to install with `pip`.
You can get a list of possible versions with `pyenv install -l`.

## Managing virtual environments
For specific projects, you probably only want to install the packages necessary for that project.
A virtualenv is essentially an isolated installation of python (and packages) which are specific to the current environment.
This lets you organize what modules you have installed, as well as the python version.

As an example, let's create a virtualenv named `my-venv`.
First, create it with
{{ cli(command="pyenv virtualenv 3.10.1 my-venv") }}
Let's say we are in a project directory where I want to use the `my-venv` virtual environment.
Simply create a file named `.python-version`, which is populated with the name of the desired virtual environment:
{{ cli(command='echo "my-venv" > .python-version') }}
Now, whenever you enter this directory, `pyenv` will automatically activate the environment, and whenever you leave, the environment will deactivate.

You can also manually activate the virtual environment with
{{ cli(command="pyenv activate my-venv") }}
and deactivate with
{{ cli(command="pyenv deactivate") }}
To get a list of all the virtual environments currently installed, run
{{ cli(command="pyenv virtualenvs") }}
You can uninstall virtual environments with
{{ cli(command="pyenv uninstall my-venv") }}
