# pass-grave
An extension for [pass](https://www.passwordstore.org/) (the standard Unix password manager) to easily hide the metadata of the password store

## Usage

```
Why a "grave"?
      pass by default shows meta-data in the password store. Someone with access
      to your computer might find ~/.password-store/email/google/johndoe@gmail.com
      and conclude you have an account with Google and the account name is
      "johndoe@gmail.com". The same for your banking information, etc.

      The idea for pass-grave comes from
      pass-tomb: https://github.com/roddhjav/pass-tomb#readme
      In order to hide this meta-data you can use pass-tomb to place the
      password store into a tomb (https://www.dyne.org/software/tomb/).
      The same you can do with this, pass-grave.

      A "grave" is similar to a tomb but a lot lighter and simpler.
      With "pass grave close" you place the complete passwordstore
      into the grave, and close the grave, reducing everything to a single
      file without any meta-data.

      With "pass grave open" you open the grave, take all the information
      out of the grave and restore the complete passwordstore to its former
      state.

      So, typically the first operation of a pass session is to open the grave
      and the very step is to close the grave.

Usage:
    $PROGRAM grave open
        On the first run it creates a directory ".grave" in \$PASSWORD_STORE_DIR.
        By default this is ~/.password-store/.grave".
        If the grave directory with a grave exists it will open it and
        restore the full password store. Once restored the grave will be removed.
        The grave is represented with the file
        ~/.password-store/.grave/passwordstore.grave.tar.gz2.gpg.
        The grave is encrypted with the pass GPG key and hence
        the content of the grave and all its meta-data is protected and
        hidden.
    $PROGRAM grave close
        If the grave does not exist, "close" creates a copy of the complete password
        store by creating a compressed tar-file with extension .tar.bz2 and
        encrypts it with the pass GPG key.
        Thereafter the password store is removed leaving only the grave file
        and other files that hold no meta-data (e.g. extensions, backups, gpg-id).
    $PROGRAM grave help
        Prints this help message.
    $PROGRAM grave version
        Prints the version number.

Example: $PROGRAM grave open
            this opens the grave at the beginning of a session
            and restores the password store from the grave file and then
            removes the grave file.
Example: $PROGRAM grave close
            this creates a copy of the password store and places it into
            a single compressed and encrypted file. Thereafter it removes
            the password store (except some files holding no meta-data)

For installation place this bash script file "grave.bash" into
the passwordstore extension directory specified with \$PASSWORD_STORE_EXTENSIONS_DIR.
By default this is ~/.password-store/.extensions.
E.g. cp grave.bash ~/.password-store/.extensions
Give the file execution permissions:
E.g. chmod 700 ~/.password-store/.extensions/grave.bash
Set the variable PASSWORD_STORE_ENABLE_EXTENSIONS to true to enable extensions.
E.g. export PASSWORD_STORE_ENABLE_EXTENSIONS=true
Source the bash completion file "pass-grave.bash.completion" for bash completion.
E.g. source ~/.password-store/.bash-completions/pass-grave.bash.completion
Type "pass grave close" to create your first grave.
E.g. pass grave close
```

## Examples

## Example 1: Opening the grave
```
$ pass grave open
```
This extracts and restores the password store from the grave and then deletes the grave.

## Example 2: Closing the grave
```
$ pass grave close
```
This creates the grave, places the complete password store into it 
and then removes the password store with its meta-data. All meta-data
is hiden now.
The grave can be found at ```$PASSWORD_STORE_DIR/.grave```
e.g. ```~/.password-store/.grave/passwordstore.grave.tar.gz2.gpg```.
            
## Installaion

For installation download and place this bash script file ```grave.bash``` into
the passwordstore extension directory specified with ```$PASSWORD_STORE_EXTENSIONS_DIR```.
By default this is ```~/.password-store/.extensions```.
```
$ cp grave.bash ~/.password-store/.extensions
```
Give the file execution permissions:
```
$ chmod 700 ~/.password-store/.extensions/grave.bash
```
Set the variable ```PASSWORD_STORE_ENABLE_EXTENSIONS``` to true to enable extensions.
```
$ export PASSWORD_STORE_ENABLE_EXTENSIONS=true
```
Download and source the bash completion file ```pass-grave.bash.completion``` for bash completion.
```
$ source ~/.password-store/.bash-completions/pass-grave.bash.completion
```
Type ```pass grave close``` to create your first grave.
```
$ pass grave close
```

## Idea came from

- `pass-tomb` from [https://github.com/roddhjav/pass-tomb#readme](https://github.com/roddhjav/pass-tomb#readme)
- `tomb` from [https://www.dyne.org/software/tomb/](https://www.dyne.org/software/tomb/)

## Requirements

- `pass` from [https://www.passwordstore.org/](https://www.passwordstore.org/)
- `tar` to be installed for zipping and compression.

## Notes

Both files are tiny: 200 lines (script) and 23 lines (autocompletion)  respectively. You can check them yourself quickly. No need to trust anyone.
