+++
title = "Managing Secrets from the Command Line"
description = "Manage secrets from the command line and scripts on UNIX-like systems."
weight = 0
date = 2022-01-16

[extra]

[taxonomies]
tags = ["cli", "pgp", "shell"]
+++
## Managing secrets programatically
Generally speaking, it's not a great idea to store password files in plain text on your computer.
However, it is often useful to be able to save and inject secrets directly into scripts, or otherwise access them from the command line.

Here are two convenient options which I personally use.

### Keyring
Perhaps the easiest option is to use the [keyring](https://pypi.org/project/keyring/) utility, which integrates nicely with the MacOS keychain.
Install it with
```
pip install keyring
```
Add secrets with
```
keyring set <secret-name> <username>
```
and retrieve them with
```
keyring get <secret-name> <username>
```
Note that this prints the secret to stdout.
To copy the output to the clipboard, simply pipe to pbcopy (on Mac OS):
```
keyring get <secret> <username> | pbcopy
```
Since keyring is also a python module, it is useful when programatically accessing secrets from within python scripts.

### Pass
Another useful option is [pass](https://www.passwordstore.org/): visit the page for installation instructions for your device.
You need to first create a new password store with an existing GPG key:
```
pass init <key-id>
```
I've written a short primer on GPG [here](@/writing/sharing-secrets-with-gnupg.md).
Add secrets with
```
pass insert <secret-name>
```
and show existing secrets with
```
pass show <secret-name>
```

Pass also provides a number of additional features, such as password generation.
For example,
```
pass generate -c <secret-name>
```
creates a new secret and copies the result to the clipboard.
This is very useful, for example, when creating new passwords for use on webpages.
See the [pass webpage](https://www.passwordstore.org/) for more many interesting features.

One downside of pass is that the default authentication flow requires command line interaction, even when your computer is unlocked (under the hood, pass uses `gpg`).
If you want to be able to access secrets without providing a password, you first need to create a GPG key with no password.
You can either use the key initialization flow directly without providing a password (run `gpg --gen-key`), or generate one using the command
```
gpg --batch --passphrase '' --quick-gen-key <no-auth-key-id> default default
```
Now, choose a subfolder to encrypt using the new key:
```
pass init -p <no-auth-foldername> <no-auth-key-id>
```
and reading secrets which are stored in this subfolder will not prompt you for a password.
The secrets are still encrypted, in the sense that the files themselves cannot be opened without the corresponding secret key.