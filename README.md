# pass-grave

An extension for [pass](https://www.passwordstore.org/) (the standard Unix password manager) to
easily hide the metadata of the password store

## Why should I use pass-grave?

pass, by default, exposes meta-data in the password store. Someone with access to your computer
might find

```
~/.password-store/email/google/johndoe@gmail.com
```

and conclude you have an account with Google and the account name is "johndoe@gmail.com". The same
goes for other sensitive information like your bank details.

The idea for pass-grave comes from [pass-tomb](https://github.com/roddhjav/pass-tomb#readme) and
[tomb](https://www.dyne.org/software/tomb/).

pass-tomb hides meta-data by placing your password store into an encrypted "tomb", which uses
cryptsetup and LUKS under the hood.

pass-grave is similar to pass-tomb but it relies on gpg to place your password store in an encrypted
"grave". Since pass also uses gpg, this makes pass-grave much more simple and lighter than
pass-tomb.

## Usage

Before you start using `pass-grave`, we **highly** recommended using `git` to ensure the data
integrity of your password store. You can also setup a bare git repository in a different location
on the same device or on a different device and use that as a remote repository to keep a backup of
your password store. A password store can be initialized as a git repository using

```
$ pass git init
```

The first step after installing pass-grave should be to execute the following command

```
$ pass grave close
```

This will create a `.grave` folder inside your password store directory and create an encrypted file
called `passwordstore.grave.tar.gz.gpg`.  This file actually contains all of your password store
data in its original form. The location of the file will be

```
$PASSWORD_STORE_DIR/.grave/passwordstore.grave.tar.gz.gpg
```

To restore your password store data from the encrypted "grave", execute

```
$ pass grave open
```

To see this help message, execute

```
$ pass grave help
```

To check the version of pass-grave, execute

```
$ pass grave version
```

## Installation

Before installing pass-grave or any other pass extension, make sure to enable extension support in
pass by setting the environment variable `PASSWORD_STORE_ENABLE_EXTENSIONS` to `true` and exporting
it

```
$ export PASSWORD_STORE_ENABLE_EXTENSIONS=true
```

Add this command to `~/.bash_profile` or `~/.profile` (depending on your installation) to activate
this environment variable permanently. You may need to re-login for these changes to take effect.

To install pass-grave using the provided `Makefile` (provided by @celenium), enter the following
commands

```
git clone https://github.com/8go/pass-grave
cd pass-grave
sudo make install
```

To install pass-grave manually, place the `grave.bash` file in the password store extensions
directory usually located at

```
~/.password-store/.extensions/
```

and make it executable. This can be done using

```
$ cp grave.bash ~/.password-store/.extensions/
$ chmod 700 ~/.password-store/.extensions/grave.bash
```

Optionally, if you want bash-completion for pass-grave, install the `pass-grave.bash.completion`
file in an appropriate location

```
$ cp pass-grave.bash.completion ~/.local/share/bash-completion/completions/pass-grave
```

## Idea came from

- `pass-tomb` from [https://github.com/roddhjav/pass-tomb#readme](https://github.com/roddhjav/pass-tomb#readme)
- `tomb` from [https://www.dyne.org/software/tomb/](https://www.dyne.org/software/tomb/)

## Requirements

- `pass` from [https://www.passwordstore.org/](https://www.passwordstore.org/)
- `tar` and `gzip` for zipping and compression

## Notes

Both files are tiny: ~200 lines (script) and 23 lines (autocompletion) respectively. You can check
them yourself quickly. No need to trust anyone.

## Contributions

- Contributions and PRs are welcome. :heart:
- A big shoutout to the contributors so far: @celenium, @Inesgor, and @moppman. :clap:
