+++
title = "Some Tricks with Unix Pass"
description = "Some convenient commands I use with the Unix Pass tool."
weight = 0
date = 2022-01-17

[extra]

[taxonomies]
tags = ["cli", "pgp"]
+++
## Pass Unix
I mainly use [pass](https://www.passwordstore.org/) as the password manager on my device.
In this article, I've collected some convenient tips for using the program.
## Showing and copying secrets
### Copy additional lines
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
The username is extracted from the first matching line of the form
```
username: <value>
```
You don't need to use `username`: any string not containing the string `: ` is fine.
If there is no matching line, the password will be immediately copied to the clipboard.

To use this function, call it like
```
psc password/name
```
Autocompletions are provided from `pass show` by the `--wraps` option.

### Updating existing passwords
You can run
```
pass generate -i password/name
```
to generate a new password into `password/name`, which only replaces the first line (preserving the other information).
With this, we can write a utility function to update existing passwords:
```
function psu --wraps='pass show'
    pass show -c $argv
    read -p 'echo "Press ENTER to generate replacement password "'
    pass generate -ic $argv > /dev/null
    echo "Copied updated password to the clipboard"
end
```
Invoke with `psu password/to/update`.

## Configuration options
The variables `PASSWORD_STORE_CHARACTER_SET` and `PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS` control the characters which are used when `pass` (resp. `pass -n`) is used to generate a new password.
[Under the hood](https://git.zx2c4.com/password-store/tree/src/password-store.sh), `pass` generates the password by piping from `/dev/urandom` and using `tr -dc` to remove characters which do not pass the allowed characters list:
```
tr -dc "$characters" < /dev/urandom
```
The default value is `[:punct:][:alnum:]` (all ascii numbers, letters, and punctionation) for the general character set, and `[:alnum:]` (only numbers and letters) for the character set with no symbols.
See `man tr` for a description of other possible options.

It is also possible to change the default password length (which is 25).
For example, if you want 50 character passwords, just
```
set -x PASSWORD_STORE_GENERATED_LENGTH 50
```

## Managing GnuPG with pass
### Create secrets which do not require authentication
First, create a `gpg` key with no passphrase:
```
gpg --batch --passphrase '' --quick-gen-key <no-auth-key-id> default default
```
Now, choose a subfolder to encrypt using the new key:
```
pass init -p <no-auth-foldername> <no-auth-key-id>
```
Any secrets stored in this subfolder will not prompt you for a password!

### Change the default timeout
When you enter your password to unlock your gpg key associated with the password store, there is a delay before you are required to provide your password again.
There are two relevant values here:

- `default-cache-ttl`, which defaults to 600 (i.e. 10 minutes), and
- `max-cache-ttl`, which defaults to 7200 (2 hours)

The value `default-cache-ttl` is how long the password remains cached from the last time you entered your password, and `max-cache-ttl` is the maximum possible time that the cache can exist.
In other words, as long as you keep using the key every 10 minutes, you will only be prompted for your password once every 2 hours.

In order to change these values, add the lines (say)
```
default-cache-ttl 3600
max-cache-ttl 86400
```
to the file `~/.gnupg/gpg-agent.conf`.
This sets the default timeout to 1 hour, and the maximum cache time to 24 hours.
