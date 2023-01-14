#!/bin/sh
source_dir=$(dirname "$0")
target_dir=${DESTDIR}/${1:-${HOME}/.local/share/icons}
target_theme_dir=${target_dir}/Gnomish

alias prettify_path="realpath -mLs --relative-base='$PWD'"
source_dir=$(prettify_path "${source_dir}")
target_theme_dir=$(prettify_path "${target_theme_dir}")

print_help() {
  echo "Usage: ./install.sh [TARGET_DIRECTORY]"
  echo ""
  echo "Positional Arguments"
  echo "  TARGET_DIRECTORY    Directory where icon theme should be installed"
  echo "                      e.g. ~/.local/share/icons, /usr/share/icons, etc."
  echo ""
  echo "Environment Variables"
  echo "  DESTDIR             Alternate Root Directory"
}

write_is_not_allowed() {
  yes=0; no=1
  if test -d "${target_theme_dir}"; then
    if test -w "${target_theme_dir}"; then
      return $no
    fi
  elif mkdir -p "${target_theme_dir}" >/dev/null 2>&1; then
    return $no
  fi

  return $yes
}

do_install() {
  OLD_PWD=$PWD
  cd "${source_dir}"

  cp -vfr icons -T "${target_theme_dir}"/apps
  cp -vf index.theme -t "${target_theme_dir}"

  cd "${OLD_PWD}"
}

do_post_install() {
  if test -n "${DESTDIR}"; then
    echo "Skipping cache generation because DESTDIR is set!" >&2
    return
  fi
  if ! type gtk-update-icon-cache >/dev/null 2>&1; then
    echo "gtk-update-icon-cache not found! Skipping cache generation." >&2
    return
  fi

  gtk-update-icon-cache -f "${target_theme_dir}" 2>&1
}


if test "$1" = "-h" || test "$1" = "--help"; then
  print_help
  exit
fi

if write_is_not_allowed; then
  echo "Permission denied! Try running with sudo." >&2
  exit 2
fi

do_install
do_post_install
