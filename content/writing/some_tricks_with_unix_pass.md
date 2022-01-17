+++
title = "Some Tricks with Unix Pass"
description = "Some convenient commands I use with the Unix Pass tool."
weight = 0
date = 2022-01-17

[extra]

[taxonomies]
tags = ["cli"]
+++
## Pass Unix
I mainly use [pass](https://www.passwordstore.org/) as the password manager on my device.
I've collected some convenient tips for using the program.
## Showing and copying secrets
### Show additional lines
You can copy lines other than the first: for example
```
pass -c2 password/name
```
copies the second line of the secret `password/name`.
### Copy login and password to clipboard
Here is a short fish shell function which first copies the login information to the clipboard, and then the password (after confirming the prompt):
```
function psc
    echo -n (pass show $argv | head -n 2 | tail -n 1 | string split ': ' -m 1 -f 2) | pbcopy
    echo "Copied $argv login to clipboard."
    read -p 'echo "Press ENTER to continue "'
    pass show -c $argv
end
```
This script assumes that the first two lines of your password file are in the following format:
```
<password>
username: <username>
```
You don't need to use `username`: any string is fine.
The split happens at the delimeter `: `.

To use this function, call it like
```
psc password/name
```

We can add completion with the following script, which simply delegates the completion to the original `pass show` command.
```
complete -c 'psc' -f -a '(begin
    set -l cmd (commandline -opc) (commandline -ct)
    set -e cmd[1 2]
    complete -C"pass show $cmd"
end)'
```
As usual, copy the contents to `completions/psc.fish`.

## Configuration options
Define a custom character set:
```
set -x PASSWORD_STORE_CHARACTER_SET 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789&~!@#$%^*_+- {}][:;?,.'
```
Specify the charcter set when `pass generate` is invoked with the option `-n`:
```
set -x PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789'
```
Set the default password length:
```
set -x PASSWORD_STORE_GENERATED_LENGTH 50
```

## Create secrets which do not require authentication
First, create a `gpg` key with no passphrase:
```
gpg --batch --passphrase '' --quick-gen-key <no-auth-key-id> default default
```
Now, choose a subfolder to encrypt using the new key:
```
pass init -p <no-auth-foldername> <no-auth-key-id>
```
Any secrets stored in this subfolder will not prompt you for a password!
