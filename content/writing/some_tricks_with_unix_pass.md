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
function psc --wraps='pass show'
    set -l username (pass show $argv | string match -r ".+:\ (.+)" | head -n 2 | tail -n 1)
    if test -n "$username"
        echo -n "$username" | pbcopy
        echo "Copied $argv login to clipboard."
        read -p 'echo "Press ENTER to continue "'
    else
        echo "$argv has no login"
    end
    pass show -c $argv
end
```
This script pulls the username from the first matching line of the form
```
username: <username>
```
You don't need to use `username`: any string is fine.
The split happens at the delimeter `: `, so spaces are fine (but not recommended in general).

To use this function, call it like
```
psc password/name
```
Autocompletions are provided from `pass show` by the `--wraps` option.

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
