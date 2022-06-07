#!/bin/bash

usage() {
    cat <<EOF
Usage: $0 <command>

Commands:
    install         Install the dotfiles (using symlinks)
    update          Update this repo as well as the submodules
    uninstall       Uninstall (remove symlinks, restore backed up files)
EOF
}

white='\033[0m'
red='\033[91m'
yellow='\033[93m'
green='\033[92m'
blue='\033[94m'
purple='\033[95m'
cyan='\033[96m'

die() {
    error "$1"
    exit 1
}

if echo -e '' | grep -F -- -e >/dev/null 2>&1; then
    echo_flag=
else
    echo_flag=-e
fi

say() {
    echo $echo_flag "$1"
}

good() {
    say "${green}[+]${white} $1"
}

info() {
    say "${blue}[*]${white} $1"
}

warn() {
    say "${yellow}[*]${white} $1"
}

error() {
    say "${red}[-]${white} $1"
}

do_install() {
    for item in _*; do
        install "$item"
    done
    install_bashrc_hook
}

do_update() {
    # git pull
    git submodule update --init --recursive
}

do_uninstall() {
    for item in _*; do
        uninstall "$item"
    done
    [ -d "$BACKUPDIR" ] && {
        find "$BACKUPDIR" -mindepth 1 -maxdepth 1 | while read item; do
            mv "$item" "$HOME/" \
                && good "Restored $item to $HOME" \
                || die "Failed to restore $item"
        done
    }
    uninstall_bashrc_hook
    good "Uninstallation finished successfully"
}

install() {
    src="$1"
    [ -z "$src" ] && die "$0 requires an argument"

    dst="$(get_target_path "$src")"
    [ "$(resolve_path "$dst")" = "$DOTFILES/$src" ] && \
        info "Already installed: $src" && \
        return 0

    backup "$dst" || die "Failed to backup $dst, aborting"

    ln -sf "$DOTFILES/$src" "$dst" \
        && good "Symlink: $src -> $dst" \
        || die "Failed to symlink: $src -> $dst"
}

uninstall() {
    dst="$(get_target_path "$1")"
    [ -e "$dst" ] || {
        return 0
    }
    [ -L "$dst" ] && {
        rm -f "$dst" \
            && good "File is uninstalled: $dst" \
            || warn "Failed to remove $dst"
    } || return 0
}

backup() {
    [ -f "$1" ] || return 0
    mkdir -p "$BACKUPDIR"
    mv "$1" "$BACKUPDIR" \
        && good "Backup $1 to $BACKUPDIR" \
        || die "Failed to backup $1 to $BACKUPDIR, aborting"
}

get_target_path() {
    [ "${1:0:1}" = _ ] \
        && echo "$HOME/.${1:1}" \
        || echo "$HOME/$1"
}

resolve_path() {
    realpath -- "$1" 2>/dev/null || readlink -f -- "$1" 2>/dev/null
}

install_bashrc_hook() {
    grep "# dotfiles-minimal" $HOME/.bashrc &>/dev/null && return 0
    cat <<EOF >> $HOME/.bashrc
[ -f "\$HOME/.bash/rc" ] && . "\$HOME/.bash/rc" # dotfiles-minimal
EOF
    [ $? -eq 0 ] && good "Appended to ~/.bashrc" || bad "Failed to append to ~/.bashrc"
}

uninstall_bashrc_hook() {
    sed -i '/# dotfiles-minimal/d' $HOME/.bashrc &>/dev/null || true
}

set -euo pipefail

DOTFILES="$(resolve_path "$BASH_SOURCE")"
DOTFILES="${DOTFILES%/*}"
BACKUPDIR="$DOTFILES/backup"
[ -f "$DOTFILES/manage.sh" ] || die "Please run with /bin/bash"

cd "$DOTFILES"
case "${1:-}" in
    install)
        do_update
        do_install;;
    update)
        do_update;;
    uninstall)
        do_uninstall;;
    *)
        usage;;
esac
