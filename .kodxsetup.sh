#!/usr/bin/env sh
# SPDX-License-Identifier: GPL-3.0-or-later
# kodx dotfiles
# Author: kodx <kodx.org>

: <<'INSTALL'
wget --hsts-file /dev/null --no-check-certificate -qO- https://raw.githubusercontent.com/kodx/dotfiles/master/.kodxsetup.sh | INSTALL=1 sh
or
curl -fsSL https://raw.githubusercontent.com/kodx/dotfiles/master/.kodxsetup.sh | INSTALL=1 sh
INSTALL

# ---------------------------------------------------------------
: <<'SETUP'
cd $HOME
git clone --bare git@github.com:kodx/dotfiles.git $HOME/.dotfiles
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout -f
SETUP

: <<'INITIALSETUP'
mkdir $HOME/.dotfiles
git init --bare $HOME/.dotfiles
alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
dotfiles config --local status.showUntrackedFiles no
dotfiles remote add origin git@github.com:kodx/dotfiles.git
dotfiles add .bashrc
dotfiles status
dotfiles commit -m "initial commit"
git push -u origin master
INITIALSETUP

: <<'USAGE'
alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
dotfiles add .profile
dotfiles status
dotfiles commit -m "The commit"
dotfiles push
USAGE
# ---------------------------------------------------------------


usage() {
    cat <<EOM
kodx dotfiles setup
Usage:

install dotfiles and applications, create dirs and fix git link
$ INSTALL=1 $0
or
$ $0 install

install dotfiles
$ INSDOTFILES=1 $0
or
$ $0 insdotfiles

install apps
$ INSAPPS=1 $0
or
$ $0 insapps

install static configs
$ INSCFGS=1 $0
or
$ $0 inscfgs

create user dirs 
$ MAKEDIRS=1 $0
or
$ $0 makedirs

fix git config link to ssh
$ FIXLINK=1 $0
or
$ $0 fixlink
EOM
}

if [ "$#" -eq 0 ] && [ -z "$INSDOTFILES" ] && [ -z "$INSAPPS" ] && [ -z "$INSTALL" ] && [ -z "$INSCFGS" ] && [ -z "$FIXLINK" ] && [ -z "$MAKEDIRS" ] ; then
    usage
    unset usage
    return 1
fi

# check is commands present
checkcmd() {
    for arg in "$@"; do
        if ! command -v "$arg" > /dev/null; then
            echo "command $arg not found, abort"
            return 1
        fi
    done
    return 0
}

# change git link in config to ssh connection
fixlink() {
    echo 'fixing git config link...'
    local _cfgpath="$HOME/.dotfiles/config"
    if [ ! -e $_cfgpath ]; then
        echo 'git config not found, abort.'
        return 1
    fi
    sed -i -- 's|https\://github\.com/|git\@github\.com\:|g' $_cfgpath
    echo 'fixing git config done.'
    return 0
}

insdotfiles() {
    echo 'installing dotfiles...'
    checkcmd 'git' || return 1

    local _dfdir="$HOME/.dotfiles"
    local _backup=''
    cd "$HOME" || return 1
    if [ -e "$_dfdir" ]; then
        _backup="$_dfdir.bak.$(date +%s)"
        mv "$_dfdir" "$_backup" || return 1
    fi
    if ! git clone --bare 'https://github.com/kodx/dotfiles.git' "$_dfdir"; then
        echo 'git clone failed'
        [ -n "$_backup" ] && mv "$_backup" "$_dfdir"
        return 1
    fi
    local dotfiles="git --git-dir=$_dfdir --work-tree=$HOME"
    $dotfiles config --local status.showUntrackedFiles no
    if ! $dotfiles checkout -f; then
        echo 'dotfiles checkout failed'
        return 1
    fi
    [ -n "$_backup" ] && rm -rf "$_backup"
    echo 'dotfiles install complete'
}

getapp() {
    [ "$#" -lt 2 ] && return 1

    local _bindir="$HOME/.local/bin"
    local _cmdpath
    _cmdpath="$_bindir/$(basename "$2")"
    mkdir -p "$_bindir"

    local _getopt=''
    case $(basename $1) in
        curl)
            _getopt='-#L -C - -o '$_cmdpath
            ;;
        wget)
            _getopt='-q --hsts-file /dev/null -N -P '$_bindir
            ;;
        *)
            echo "get command $1 unknown, abort"
            return 1
            ;;
    esac

    echo "downloading $2"
    # shellcheck disable=SC2086 # _getopt holds several options on purpose
    $1 "$2" $_getopt
    [ -f "$_cmdpath" ] && chmod u+rx "$_cmdpath"
    return 0
}

# return first avialable command full path
getcmd() {
    for e in "$@"; do
        command -v "$e" > /dev/null && command -v "$e" && return 0
    done
    return 1
}


insapps() {
    echo 'installing applications ...'
    local _getcmd
    _getcmd=$(getcmd 'curl wget') || return 1
    checkcmd 'basename mkdir chmod' || return 1

    # set apps urls
    local _mapps='
        https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
        https://raw.githubusercontent.com/kodx/lightsOn/master/lightsOn.sh'

    for e in $_mapps; do
        getapp $_getcmd $e
    done

    echo 'applications install complete'
    return 0
}

inscfgs() {
    # exit if commands not found
    checkcmd 'base64 gunzip' || return 1

    # gzip -c ~/.config/mc/panels.ini | base64
    local _mcpcfg='
H4sICAAAAAAC/3BhbmVscy5pbmkA7dOxagMxDAbgXU/hR2gTugS8dSyldC3BuHe/E4HtOyRd0pQ8
fO4uV+jQQrYuXWwjPgz6hejtGUf3hGTuJVbkLbWsfY4nn1mN644EB4jCp5gV1ERFUFRl48NXER9o
QmJRWwraiYVOWoivsYCmv0LpWvhBITQdIXVSovl9zMnZqYebpDs75U9sHsbH5DfrK1aLNujdz3q8
ekj5Lu9vlqub5fpXWYzHJmdauPLivckAondhpNB0Wf2Krkksrc9Z0DyAV97t/yfwVxN4HIPbUjOI
oFpgDXnchyVIugAtzU5cIgMAAA=='
    # gzip -c ~/.config/mc/ini | base64
    local _mccfg='
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'
    # gzip -c ~/.config/qBittorrent/qBittorrent.conf | base64
    local _qbcfg='
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
/Af2NfiIOCsAAA=='

    local _mcpath=$HOME/.config/mc
    local _qbpath=$HOME/.config/qBittorrent
    [ -d $_mcpath ] && echo "$_mccfg" | base64 -d | gunzip > $_mcpath/ini
    [ -d $_mcpath ] && echo "$_mcpcfg" | base64 -d | gunzip > $_mcpath/panels.ini
    [ -d $_qbpath ] && echo "$_qbcfg" | base64 -d | gunzip > $_qbpath/qBittorrent.conf
    return 0
}

makedirs() {
    echo 'creating directories...'
    cd "$HOME" || return 1
    local _dirlist='
        desktop
        docs
        docs/share
        docs/templates
        download
        devel
        storage
    '
    for e in $_dirlist; do
        mkdir -pv "$e"
    done
    echo 'creating directories complete'
    return 0
}

if [ -n "$INSTALL" ] || [ "$1" = 'install' ]; then
    insdotfiles || exit 1
    inscfgs || exit 1
    insapps || exit 1
    makedirs || exit 1
    fixlink || exit 1
else
    if [ -n "$INSDOTFILES" ] || [ "$1" = 'insdotfiles' ]; then insdotfiles || exit 1; fi
    if [ -n "$INSAPPS" ] || [ "$1" = 'insapps' ]; then insapps || exit 1; fi
    if [ -n "$INSCFGS" ] || [ "$1" = 'inscfgs' ]; then inscfgs || exit 1; fi
    if [ -n "$FIXLINK" ] || [ "$1" = 'fixlink' ]; then fixlink || exit 1; fi
    if [ -n "$MAKEDIRS" ] || [ "$1" = 'makedirs' ]; then makedirs || exit 1; fi
fi

unset insdotfiles insapps usage getapp getcmd inscfgs checkcmd fixlink makedirs
