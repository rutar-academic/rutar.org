+++
title = "A brief introduction to Git for small-scale collaboration"
description = "An introduction and opinionated list of best practices for using Git with a small number of collaborators"
date = 2024-09-22
draft = true

[extra]
toc = true

[taxonomies]
tags = ["cli", "git"]
+++
## A brief introduction to git
The goal of this article is not to provide a comprehensive introduction to Git.
For that purpose, I would recommend the excellent and free [Pro Git](...) book; at the very least, read the introduction to get fully set up on your device.
In particular, at the very least:

1. You should have Git installed on your device along with command line interface (if you are using MacOS or a Linux distribution, this should be natural; if you are using a Windows machine, you should look for the "Git Bash" interface).
2. You should have a basic understanding of navigating filesystems using the command line.
3. You have some a basic familiarity with using git, and have successfully created or cloned a repository from a remote source, committed to it, and pushed to a remote server.


## A mental model for Git state
In order to understand how to use Git, it is often very helpful to have a working mental model of how Git represents the state.

All of the state tracked by Git is stored in a special folder at the root of the repository called `.git`.
### Snapshots
The filesystem is perhaps the most fundamental abstraction of a computer system.
However, it has some obvious limitations.
For instance, what happens if:

- you make a destructive change, and want to recover from it?
- multiple people want to edit the same set of files, at the same time?
- you wish to keep track of how the set of files has changed over time?

This is the core abstraction of Git: it models how a *filesystem* evolves over *time*.
The fundamental unit on which this abstraction is built is the *snapshot*.

A snapshot is simply an image of a portion of your filesystem at a particular moment in time.
In Git, snapshots also have *integrity*: associated with each snapshot is a [SHA-1 hash](https://en.m.wikipedia.org/wiki/SHA-1https://en.m.wikipedia.org/wiki/SHA-1), which looks (for instance) like
```
2b07d1e84110e01bc13c0c63e2d0b1cff13151fc
```
This SHA-1 hash is a way to refer uniquely{% inline_note() %}Unfortunately, SHA-1 is now [broken in practice](https://shattered.io/), but this is mainly an issue for maliciously crafted commits and will essentially never occur by accident. A lot of providers have [mitigations](https://github.blog/news-insights/company-news/sha-1-collision-detection-on-github-com/).{% end %} to a snapshot.
SHA-1 hashes are widespread throughout Git, and used to identify objects other than snapshots, and you will see them almost everywhere.

At its core, you might find it useful to think about Git as a collection of snapshots along with ordered relationships (the structure of a directed graph) between snapshots.

### Untracked, staged, and committed
Not all state in Git is necessarily embedded inside a commit.
You can also have working changes inside your repository.
By default, any changes in your repository which are not stored in a commit are *untracked*.
These are changes which Git is not aware of at all, and if you modify untracked changes, nothing will be recorded.

You can move changes from the untracked to the *staged* state using the `git add <file>` command, and move changes from the *staged* to *untracked* stage using `git restore --staged <file>`.

Once some changes have been *staged*, all of the staged changes can be wrapped and converted to a commit using `git commit`.

Note that any changes in your working directory which are not committed are fundamentally ephemeral, and can easily be lost if you are not careful.
On the other hand, commits are more permanent.

### `HEAD`, branches, and tags
In order to organize the graph of snapshots, Git uses what are essentially *pointers* or *labels* for snapshots.

*Branches* are essentially pointers to commits.
When you initialize a new Git repository and commit to it, any changes are made to a default branch (often called `master` or `main`).
Whenever a commit is added to a branch, the branch pointer automatically moves to point at the tip of the branch.

In contrast, *tags* are also pointers to commits, but unlike branches, tags do not move to follow the tip of a branch.
One can think of a tag more directly as an alternative human-friendly name to refer to a specific commit instead of a commit hash.
Tags can also carry additional data if created with `git tag <tag> -m <info>`.

Another special type of pointer is `HEAD`.
The most common state is for `HEAD` to point at a branch: this is the default state, and also what happens when you switch to a different branch using `git switch`.
However, it is also possible for `HEAD` to point directly to a commit, which is a state known as *detached *`HEAD`.
This distinction is important because of how Git keeps track of which objects are important to retain.
Essentially, if an object is not an ancestor of a tag, not part of a branch, or not an ancestor of `HEAD` when `HEAD` is in detached state, Git could decide to delete the corresponding objects from history.

You can determine your current branch by running `git status` or `git branch`.
The branch labels also appear when you run `git log`.
For instance, the output of `git log --oneline` might return
```
67e3e08 (HEAD -> master) Add new article
2679401 Update webpage content
0e410b1 First commit
```
Here, we can see `HEAD -> master`, which means that `HEAD` is tracking the `master` branch.
In contrast, in detached `HEAD` state, this could instead look like
```
67e3e08 (HEAD, master) Add new article
2679401 Update webpage content
0e410b1 First commit
```
Even though `HEAD` points to the exact same commit `67e3e08`, this distinction is important since changes at `HEAD` do not belong to the `master` branch.

Note that all of these values can also be determined quite transparently in the `.git` folder; check out the files `.git/HEAD`, `.git/ORIG_HEAD`, and the folder `.git/refs/heads/`.

In order to change the current state of `HEAD`, there are (rather confusingly) a few options.
The most common is the `git switch <branch>` command, which swaps to a different branch.
It is also possible to point directly at a commit using `git checkout <commit_hash>`.
On the other hand, `git checkout <branch>` will also work.
To create a new branch, you can use `git branch <name>`, or `git checkout -b <name>`, or `git switch -c <name>`.
The latter two commands simultaneously create the new branch and also switch to it.

Note that if you have untracked changes in your repository, Git will likely warn that switching will discard your changes.
When you swap branches, the actual state of your filesystem will change!

### Remotes
The final core piece of Git is the notion of a *remote*.
A remote is a type of reference to *another* Git repository.
A remote does not need to refer to a Git repository that is actually on a different computer: a remote could simply be another Git repository in a different folder.
To create a new remote, one runs
```
git remote add <name> <source>
```
Remotes can have branches, such as `origin/master`, which is a different branch than `master`.
In order to synchronize the state of a remote branch with a local branch, one uses the `git push` command.
For instance,
```
git push origin master
```
says "update the remote branch master to track the state of the current branch, and also send all of the objects required for this to make sense".

You can also set the remote branch as a tracking branch, with
```
git push -u origin master
```
Here, `-u` is short for `--set-upstream`.
In this case, in the future, `git push` will automatically know which remote branch to push to, without requiring the `origin master` qualification.


## Rebasing
