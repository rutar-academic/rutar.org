+++
title = "Sharing Secrets with GnuPG"
description = "How and why I changed my work environment from a combination of vim and tmux to neovim."
date = 2021-04-14

[extra]

[taxonomies]
tags = ["pgp"]
+++
In this article, I will discuss some of basic aspects of creating and using [GnuPG](https://gnupg.org/) to manage [PGP](https://www.openpgp.org/) keys for sharing of information.

Public key encryption is essentially a means of enabling one-way communication between two parties.
You generate a keypair, consisting of a public key and a private key, secure the private key, and share the public key.
Anybody who has your public key can use it to encrypt data, which then can only be decrypted with your private key.

A useful analogy is that a public key is like an open safe with no key: anybody can put a document inside the safe and shut the door, but once the safe door is closed, only the person with the key can open it.

I will review the usage of the `gpg` command line tool, which is a commonly used implementation of the pgp standard.
## Creating and using a new keypair

### Keypair creation
To get started, you want to generate a new keypair.
Do this with the command
```
$ gpg --full-generate-key
```
You will be prompted to answer some questions about the key you are generating, and at the end, you will have to enter a passphrase to protect the new key.

Now that you have a keypair, you can export your public key with
```
$ gpg --output my_pubkey.asc --armor --export user@email
```
where `user@gmail` is the email address that you are chose when generating the keypair.

If you want to back up your secret key and save it to a secure location, run
```
$ gpg --output backupkeys.asc --armor --export-secret-keys --export-options export-backup user@email
```
Make sure to save this file in a secure location.

### Encrypting and decrypting files

Of course, generating and sharing your own public key only only gives you a one-directional secure communication channel.
In order to encrypt data to send to someone else, you first need their public key `pubkey.asc`.

Import it to your keyring with
```
$ gpg --import pubkey.asc
```
If you run `gpg --list-keys`, you should now see an additional entry containing the details of the new public key you just imported.
Now, to encrypt the file `filename` to the file `secure.gpg` for recipient `recipient@gmail`, just run
```
$ gpg --output secure.gpg --encrypt --recipient recipient@email filename
```
and the file has now been secured with the public key.
You can also optionally sign the encrypted file with the `--sign` option.

On the other hand, if you have received an encrypted file `secure.gpg` sent to you using your public key, just run
```
$ gpg --output filename --decrypt secure.gpg
```
to create the decrypted file `filename`.
Note that `gpg` automatically worked out the correct key to use to decrypt the file, and this command will fail if the file was not encrypted with any private key in your keyring.

### Anatomy of a keyring listing
You can list the public keys available on your device with
```
$ gpg --list-keys
$USER/.local/share/gnupg/pubring.kbx
------------------------------------
pub   rsa2048 2021-04-13 [SC]
      IU9VN34O2NOI9M3L409U8JS8210KZMCN39M5KD93
uid           [ultimate] Your Name (local) <user@email>
sub   rsa2048 2021-04-13 [E]
```
At the top, we can see the filename where the keyring is stored along with a divider, followed by a sequence of text blocks.
In each block:

- The first line `pub` indicates that the key is a public key.
The long string of characters in the second line is known the _fingerprint_ of the key.
The last 8 characters, in this case `39M5KD93` is the _short key id_, and the last 16 characters `210KZMCN39M5KD93` are known as the _long key id_.
You can also view these more easily by including the option `--keyid-format short` or `--keyid-format long` in `gpg --list-keys`.
- The `uid` contains identification for the user
- The `sub` contains details about the key itself, such as the encryption protocol, creation date, and optional expiry date.

You can also list your private keys with `gpg --list-private-keys`, in the same way as above.

## Keyservers, signing, and revocation certificates
### Sending and receiving keys from a keyserver
One method to share public keys with other users is to use a _key server_.
This is essentially an online database containing a large list of public keys.
A note of caution: keyservers are typically write-only so it is not possible to delete a key once you have uploaded it to the server.

For example, to submit your public key to the default keyserver, run
```
$ gpg --send-key user@gmail
```
If you know the key id of a public key on a certain keyserver, you can also import the key with
```
$ gpg --recv-key key_id
```
For example, you can add my public key to your keychain by replacing `key_id` with `A7B3FED0`.

Despite the convenience, using keyservers introduces new complications surrounding with key management.
These can be essentially subdivided into two sections:

1. Establishing trust
2. Removing published keys

I will discuss these two issues in the subsequent sections.

### Establishing trust and key signing
Note: under construction.
- [key revocation](http://www.spywarewarrior.com/uiuc/ss/revoke/pgp-revoke.htm)
- [key signing](https://gist.github.com/F21/b0e8c62c49dfab267ff1d0c6af39ab84)
- [more key signing](https://www.digitalocean.com/community/tutorials/how-to-use-gpg-to-encrypt-and-sign-messages)
- [key backup](https://www.saminiir.com/paper-storage-and-recovery-of-gpg-keys/)
- [subkeys?](https://www.saminiir.com/establish-cryptographic-identity-using-gnupg/#creating-the-master-key)


<!-- "In general, it's not advisable to post personal public keys to key servers. There is no method of removing a key once it's posted and there is no method of ensuring that the key on the server was placed there by the supposed owner of the key." -->

