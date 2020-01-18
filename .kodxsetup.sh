#!/usr/bin/env sh
# kodx dotfiles
# Author: kodx <kodx.org>

: <<'INSTALL'
wget --hsts-file /dev/null --no-check-certificate -qO- https://raw.githubusercontent.com/kodx/dotfiles/master/.kodxsetup.sh | INSALL=1 sh
or
curl -fsSL https://raw.githubusercontent.com/kodx/dotfiles/master/.kodxsetup.sh | INSALL=1 sh
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

    install dotfiles and applications
    $ INSALL=1 $0
    or
    $ $0 insall

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

    fix git config link to ssh
    $ FIXLINK=1 $0
    or
    $ $0 fixlink
EOM
}

if [ "$#" -eq 0 ] && [ ! $INSDOTFILES ] && [ ! $INSAPPS ] && [ ! $INSALL ] && [ ! $INSCFGS ] && [ ! $FIXLINK] ; then
    usage
    unset usage
    return 0
fi

# check is commands present
checkcmd() {
    for arg in $@; do
        if ! $(command -v "$arg" > /dev/null); then
            echo "command $arg not found, abort"
            return 1
        fi
    done
    return 0
}

# change git link in config to ssh connection
fixgitlink() {
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
    [ -d $_dfdir ] && rm -rf $_dfdir
    cd $HOME
    git clone --bare 'https://github.com/kodx/dotfiles.git' $_dfdir
    local dotfiles="git --git-dir=$_dfdir --work-tree=$HOME"
    $dotfiles config --local status.showUntrackedFiles no
    $dotfiles checkout -f
    echo 'dotfiles install complete'
    return 0
}

getapp() {
    [ "$#" -lt 2 ] && return 1

    local _bindir="$HOME/bin"
    local _cmdpath="$_bindir/$(basename $2)"
    mkdir -p $_bindir

    local _getopt=''
    case $(basename $1) in
        curl)
            _getopt='-#L -C - -o '$_cmdpath
            ;;
        wget)
            _getopt='-q --hsts-file /dev/null -nv -N --show-progress -P '$_bindir
            ;;
        *)
            echo 'get command $1 unknown, abort'
            return 1
            ;;
    esac

    echo "downloading $2"
    $1 $2 $_getopt
    [ -f $_cmdpath ] && chmod u+rx $_cmdpath
    return 0
}

# return first avialable command full path
getcmd() {
    for e in $@; do
        $(command -v "$e" > /dev/null) && echo $(command -v "$e") && return 0
    done
    return 1
}


insapps() {
    echo 'installing applications ...'
    local _getcmdlist='curl wget '
    checkcmd 'basename mkdir chmod' $_getcmdlist || return 1

    local _getcmd=$(getcmd $_getcmdlist)
    # set apps urls
    local _mapps='
        https://yt-dl.org/downloads/latest/youtube-dl
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
H4sICB2c7V0AA3BhbmVscy5pbmkA7dPNSgMxEAfw+zxF3qDa4qWQm0cR8VpKiJtJdzAfy8xsbcWH
N7tdwYNCb168JGH4JTD/IbB7xDfzgFHNky+Y9hBIhuTPNpEolQMwHpEFbfRJEDov6ASLkNLxq4gn
7FwkFl0KUlld5YBsi88I01su14B2FGSYFhcrZ6+29ykaPQ9oJmk+jNA7bu/aYfLbzQWLeh3l5mfd
tgE5f5e3V8v11XLzq8xKrcmZZiq0eKs8IsALE0bX1SR2DZckltbnLGAewDMd+v8J/NUE7ltwe6ja
t+uB2K76mnH1WsMJupEZizoSl9onWdKFT8SD9ZQ3AwAA'
    # gzip -c ~/.config/mc/ini | base64
    local _mccfg='
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'
    # gzip -c ~/.config/qBittorrent/qBittorrent.conf | base64
    local _qbcfg='
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
B0wBVkQ4dC2QX/P8GwEKY/BkLQAA'

    local _mcpath=$HOME/.config/mc
    local _qbpath=$HOME/.config/qBittorrent
    [ -d $_mcpath ] && echo "$_mccfg" | base64 -d | gunzip > $_mcpath/ini
    [ -d $_mcpath ] && echo "$_mcpcfg" | base64 -d | gunzip > $_mcpath/panels.ini
    [ -d $_qbpath ] && echo "$_qbcfg" | base64 -d | gunzip > $_qbpath/qBittorrent.conf
    return 0
}

if [ $INSALL ] || $(test "$1" = 'insall'); then
    insdotfiles
    inscfgs
    insapps
    fixgitlink
else
    [ $INSDOTFILES ] || [ "$1" = 'insdotfiles' ] && insdotfiles
    [ $INSAPPS ] || [ "$1" = 'insapps' ] && insapps
    [ $INSCFGS ] || [ "$1" = 'inscfgs' ] && inscfgs
    [ $FIXLINK] || [ "$1" = 'fixlink' ] && fixgitlink
fi

unset insdotfiles insapps usage getapp getcmd inscfgs checkcmd fixgitlink
