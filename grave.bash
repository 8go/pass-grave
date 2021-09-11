#!/usr/bin/env bash
# pass grave - Password Store Extension (https://www.passwordstore.org/)
# Copyright (C) 2019
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# []

VERSION="1.1.1"
PASSWORD_STORE_GRAVE_DEBUG=false                    # true or false, prints debugging messages
PASSWORD_STORE_GRAVE_DIR=".grave"                   # default directory is $PASSWORD_STORE_GRAVE_DIR; $PREFIX/$PASSWORD_STORE_GRAVE_DIR
PASSWORD_STORE_GRAVE_BASENAME="passwordstore.grave" # grave will become passwordstore.grave.tar.gz.gpg
TAR=$(command -v tar)

cmd_grave_usage() {
  cat <<- _EOF
Why should I use pass-grave?
      pass, by default, shows meta-data in the password store. Someone with
      access to your computer might find

      ~/.password-store/email/google/johndoe@gmail.com

      and conclude you have an account with Google and the account name is
      "johndoe@gmail.com". The same goes for other sensitive information like
      your bank details.

      The idea for pass-grave comes from

      pass-tomb: https://github.com/roddhjav/pass-tomb#readme
      tomb:      https://www.dyne.org/software/tomb/

      pass-tomb hides meta-data by placing your password store into an
      encrypted "tomb", which uses cryptsetup and LUKS under the hood.
      pass-grave is similar to pass-tomb but it relies on gpg to place your
      password store in an encrypted "grave". Since pass also uses gpg, this
      makes pass-grave much more simple and lighter than pass-tomb.

Usage:
      The first step after installing pass-grave should be to execute the
      following command

      $ pass grave close

      This will create a '.grave' folder inside your password store directory
      and create an encrypted file called 'passwordstore.grave.tar.gz.gpg'.
      This file actually contains all of your password store data in its
      original form. The location of the file will be

      $PREFIX/.grave/passwordstore.grave.tar.gz.gpg

      To restore your password store data from the encrypted "grave", execute
      
      $ pass grave open

      To see this help message, execute

      $ pass grave help

      To check the version of pass-grave, execute

      $ pass grave version

Install:
      To install pass-grave, place the 'grave.bash' file in the password store
      extensions directory located at

      $EXTENSIONS

      and make it executable. This can be done using

      $ cp grave.bash $EXTENSIONS
      $ chmod 700 $EXTENSIONS/grave.bash

      Optionally, if you want bash-completion for pass-grave, install the
      'pass-grave.bash.completion' file in an appropriate location
      
      $ cp pass-grave.bash.completion ~/.local/share/bash-completion/completions/pass-grave

      Finally, to enable extension support in pass, set the environment
      variable PASSWORD_STORE_ENABLE_EXTENSIONS to true and export it

      $ export PASSWORD_STORE_ENABLE_EXTENSIONS=true

      Add this command to ~/.bash_profile or ~/.profile (depending on your
      installation) to activate this environment variable permanently. You may
      need to re-login for these changes to take effect.
_EOF
  exit 0
}

cmd_grave_version() {
  echo $VERSION
  exit 0
}

cmd_grave_open() {
  PASSWORD_STORE_GRAVE_PATH="$PASSWORD_STORE_GRAVE_DIR/${PASSWORD_STORE_GRAVE_BASENAME}.tar.gz.gpg" # path includes filename
  $PASSWORD_STORE_GRAVE_DEBUG && echo "Setting grave directory to $PASSWORD_STORE_GRAVE_DIR"
  $PASSWORD_STORE_GRAVE_DEBUG && echo "Setting grave file to $PASSWORD_STORE_GRAVE_PATH"
  $PASSWORD_STORE_GRAVE_DEBUG && echo "Password storage directory is $PREFIX"

  pushd "$PREFIX" > /dev/null || die "Could not cd into directory $PREFIX. Aborting."

  # does the grave already exist?
  [[ ! -f "$PASSWORD_STORE_GRAVE_PATH" ]] && {
    echo "The grave (file $PASSWORD_STORE_GRAVE_PATH) does not exist."
    echo "Maybe \"open\" was called twice in a row? "
    echo "Maybe \"close\" should be called first? "
    die "Aborting."
  }

  # file does exist
  mkdir -p "${PASSWORD_STORE_GRAVE_DIR}" > /dev/null || die "Could not create directory $PASSWORD_STORE_GRAVE_DIR. Aborting."
  $PASSWORD_STORE_GRAVE_DEBUG && echo $GPG -d "${GPG_OPTS[@]}" "$PASSWORD_STORE_GRAVE_PATH" \| tar xz
  $GPG -d "${GPG_OPTS[@]}" "$PASSWORD_STORE_GRAVE_PATH" | tar xz || die "Could not decrypt or untar grave $PASSWORD_STORE_GRAVE_PATH. Aborting."
  rm -f "$PASSWORD_STORE_GRAVE_PATH" || die "Could not remove grave $PASSWORD_STORE_GRAVE_PATH. Please remove manually. Aborting."
  echo "Recreated password store from grave file \"${PASSWORD_STORE_GRAVE_PATH}\" successfully."
  echo "You can now operate on your password store normally. Use \"grave close\" at the end of session to hide meta-data."
  popd > /dev/null || die "Could not change directory. Aborting."
}

cmd_grave_close() {
  PASSWORD_STORE_GRAVE_PATH="$PASSWORD_STORE_GRAVE_DIR/${PASSWORD_STORE_GRAVE_BASENAME}.tar.gz.gpg" # path includes filename
  $PASSWORD_STORE_GRAVE_DEBUG && echo "Setting grave directory to $PASSWORD_STORE_GRAVE_DIR"
  $PASSWORD_STORE_GRAVE_DEBUG && echo "Setting grave file to $PASSWORD_STORE_GRAVE_PATH"
  $PASSWORD_STORE_GRAVE_DEBUG && echo "Password storage directory is $PREFIX"

  pushd "$PREFIX" > /dev/null || die "Could not cd into directory $PREFIX. Aborting."

  # does the grave already exist?
  [[ -f "$PASSWORD_STORE_GRAVE_PATH" ]] && {
    echo "The grave (file $PASSWORD_STORE_GRAVE_PATH) already exists.  "
    echo "Maybe \"close\" was called twice in a row? "
    echo "Maybe \"open\" should be called first? "
    echo "For safety reasons pass-grave will not overwrite it."
    echo "If you know what you are doing you can remove the grave (file $PASSWORD_STORE_GRAVE_PATH) manually."
    die "Aborting."
  }

  mkdir -p "${PASSWORD_STORE_GRAVE_DIR}" > /dev/null || die "Could not create directory $PASSWORD_STORE_GRAVE_DIR. Aborting."
  set_gpg_recipients "$(dirname "$PREFIX")"
  $PASSWORD_STORE_GRAVE_DEBUG && echo tar --exclude ".gpg-id" --exclude=".extensions" --exclude=".backups" -cz . \| $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$PASSWORD_STORE_GRAVE_PATH" "${GPG_OPTS[@]}"
  tar --exclude ".gpg-id" --exclude=".grave" --exclude=".extensions" --exclude=".backups" -cz . | $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$PASSWORD_STORE_GRAVE_PATH" "${GPG_OPTS[@]}" || die "Creating encrypted grave failed. Aborting." # add v for debugging if need be
  chmod 400 "${PASSWORD_STORE_GRAVE_PATH}" > /dev/null || die "Could not change permissions to read-only on file $PASSWORD_STORE_GRAVE_PATH. Aborting."
  GZSIZE=$(wc -c < "${PASSWORD_STORE_GRAVE_PATH}") # returns size in bytes
  echo "Created grave file \"${PASSWORD_STORE_GRAVE_PATH}\" of size ${GZSIZE} bytes."
  find . ! -name '.gpg-id' ! -name '.' ! -name '..' ! -path './.grave' ! -path './.grave/*' ! -path './.extensions' ! -path './.extensions/*' ! -path './.backups' ! -path './.backups/*' -delete || die "Removing password store after having created grave failed. Aborting."
  popd > /dev/null || die "Could not change directory. Aborting."
}

cmd_grave_openclose() {
  # expect 1 argument
  [[ $# -lt 1 ]] && die "Need 1 argument. Use one of: open, close, help, version"
  [[ $# -gt 1 ]] && die "Too many arguments. At most 1 argument allowed: open, close, help, version"
  [[ -z "$TAR" ]] && die "Failed to generate grave: tar is not installed."
  if [ "${1,,}" == "open" ]; then
    cmd_grave_open
  elif [ "${1,,}" == "close" ]; then
    cmd_grave_close
  else
    die "Invalid argument. Use one of: open, close, help, version"
  fi
}

case "$1" in
  help | --help | -h)
    shift
    cmd_grave_usage "$@"
    ;;
  version | --version | -v)
    shift
    cmd_grave_version "$@"
    ;;
  *) cmd_grave_openclose "$@" ;;
esac
exit 0
