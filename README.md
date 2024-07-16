# Encrypted Backup Folder

This Bash script backups a specific folder to an encreypted archive TAR and upload this in a remote server by SSH.

All you need is to generate a GPG keys pair.  
The script will use only the public key.

> 🚨 It's more safe to remove the secret key to your computer and save it on one or more other devices.

## Requirements

First, we have to create a GPG keys pair which will be used to create encrypted archive.

Please be attention to retain the **Real name** of this key, it will be used in our script.

```bash
$ gpg --full-generate-key # I choosed RSA keys 4096 bits long and expire in 1 year
gpg (GnuPG) 2.2.27; Copyright (C) 2021 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
  (14) Existing key from card
Your selection?
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (3072) 4096
Requested keysize is 4096 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 365
Key expires at Wed Jul 16 15:20:42 2025 CEST
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: GPG Public Key Full Name
Email address:
Comment:
You selected this USER-ID:
    "GPG Public Key Full Name"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: key xxx marked as ultimately trusted
gpg: revocation certificate stored as '/home/bruno/.gnupg/openpgp-revocs.d/xxx.rev'
public and secret key created and signed.
```

If you create keys on an another computer, your key will be marked to unknown trusted state when import.  
To force your OS to trust your key, you need the following : 

```bash
$ gpg --edit-key "<GPG Public Key Full Name>"
> trust
Décidez maintenant de la confiance que vous portez en cet utilisateur pour
vérifier les clefs des autres utilisateurs (en regardant les passeports, en
vérifiant les empreintes depuis diverses sources, etc.)

  1 = je ne sais pas ou n'ai pas d'avis
  2 = je ne fais PAS confiance
  3 = je fais très légèrement confiance
  4 = je fais entièrement confiance
  5 = j attribue une confiance ultime
  m = retour au menu principal

Quelle est votre décision ? 5
Voulez-vous vraiment attribuer une confiance ultime à cette clef ? (o/N) o
```

Some useful commands :

```bash
$ gpg --list-secret-keys # List keys
$ gpg --list-secret-keys # List secret keys
$ gpg --output private.gpg --armor --export-secret-keys <ID> # Export a secret key
$ gpg --delete-secret-keys <ID> # Delete a secret key
```

## Apply

You can test your script by execute it to your terminal and observe the output.

```bash
$ chmod +x /Scripts/encryptedRemoteBackup.sh
$ /Scripts/encryptedRemoteBackup.sh
```

You can periodically execute this script by using a cron

```bash
$ crontab -l
# m h  dom mon dow   command
00 22 1-7 * * /Scripts/encryptedRemoteBackup.sh
```