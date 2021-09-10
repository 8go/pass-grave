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
PASSWORD_STORE_GRAVE_BASENAME="passwordstore.grave" # grave will become passwordstore.grave.tar.gz2.gpg
TAR=$(command -v tar)

cmd_grave_usage() {
  cat <<-_EOF
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
        On the first run it creates a directory ".grave" in \$PREFIX.
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

  pushd "$PREFIX" >/dev/null || die "Could not cd into directory $PREFIX. Aborting."

  # does the grave already exist?
  [[ ! -f "$PASSWORD_STORE_GRAVE_PATH" ]] && {
    echo "The grave (file $PASSWORD_STORE_GRAVE_PATH) does not exist."
    echo "Maybe \"open\" was called twice in a row? "
    echo "Maybe \"close\" should be called first? "
    die "Aborting."
  }

  # file does exist
  mkdir -p "${PASSWORD_STORE_GRAVE_DIR}" >/dev/null || die "Could not create directory $PASSWORD_STORE_GRAVE_DIR. Aborting."
  $PASSWORD_STORE_GRAVE_DEBUG && echo $GPG -d "${GPG_OPTS[@]}" "$PASSWORD_STORE_GRAVE_PATH" \| tar xz
  $GPG -d "${GPG_OPTS[@]}" "$PASSWORD_STORE_GRAVE_PATH" | tar xz || die "Could not decrypt or untar grave $PASSWORD_STORE_GRAVE_PATH. Aborting."
  rm -f "$PASSWORD_STORE_GRAVE_PATH" || die "Could not remove grave $PASSWORD_STORE_GRAVE_PATH. Please remove manually. Aborting."
  echo "Recreated password store from grave file \"${PASSWORD_STORE_GRAVE_PATH}\" successfully."
  echo "You can now operate on your password store normally. Use \"grave close\" at the end of session to hide meta-data."
  popd >/dev/null || die "Could not change directory. Aborting."
}

cmd_grave_close() {
  PASSWORD_STORE_GRAVE_PATH="$PASSWORD_STORE_GRAVE_DIR/${PASSWORD_STORE_GRAVE_BASENAME}.tar.gz.gpg" # path includes filename
  $PASSWORD_STORE_GRAVE_DEBUG && echo "Setting grave directory to $PASSWORD_STORE_GRAVE_DIR"
  $PASSWORD_STORE_GRAVE_DEBUG && echo "Setting grave file to $PASSWORD_STORE_GRAVE_PATH"
  $PASSWORD_STORE_GRAVE_DEBUG && echo "Password storage directory is $PREFIX"

  pushd "$PREFIX" >/dev/null || die "Could not cd into directory $PREFIX. Aborting."

  # does the grave already exist?
  [[ -f "$PASSWORD_STORE_GRAVE_PATH" ]] && {
    echo "The grave (file $PASSWORD_STORE_GRAVE_PATH) already exists.  "
    echo "Maybe \"close\" was called twice in a row? "
    echo "Maybe \"open\" should be called first? "
    echo "For safety reasons pass-grave will not overwrite it."
    echo "If you know what you are doing you can remove the grave (file $PASSWORD_STORE_GRAVE_PATH) manually."
    die "Aborting."
  }

  mkdir -p "${PASSWORD_STORE_GRAVE_DIR}" >/dev/null || die "Could not create directory $PASSWORD_STORE_GRAVE_DIR. Aborting."
  set_gpg_recipients "$(dirname "$PREFIX")"
  $PASSWORD_STORE_GRAVE_DEBUG && echo tar --exclude ".gpg-id" --exclude=".extensions" --exclude=".backups" --exclude=".bash-completions" -cz . \| $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$PASSWORD_STORE_GRAVE_PATH" "${GPG_OPTS[@]}"
  tar --exclude ".gpg-id" --exclude=".grave" --exclude=".extensions" --exclude=".backups" --exclude=".bash-completions" -cz . | $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$PASSWORD_STORE_GRAVE_PATH" "${GPG_OPTS[@]}" || die "Creating encrypted grave failed. Aborting." # add v for debugging if need be
  chmod 400 "${PASSWORD_STORE_GRAVE_PATH}" >/dev/null || die "Could not change permissions to read-only on file $PASSWORD_STORE_GRAVE_PATH. Aborting."
  GZSIZE=$(wc -c <"${PASSWORD_STORE_GRAVE_PATH}") # returns size in bytes
  echo "Created grave file \"${PASSWORD_STORE_GRAVE_PATH}\" of size ${GZSIZE} bytes."
  find . ! -name '.gpg-id' ! -name '.' ! -name '..' ! -path './.grave' ! -path './.grave/*' ! -path './.extensions' ! -path './.extensions/*' ! -path './.backups' ! -path './.backups/*' ! -path './.bash-completions' ! -path './.bash-completions/*' -delete || die "Removing password store after having created grave failed. Aborting."
  popd >/dev/null || die "Could not change directory. Aborting."
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
