#!/usr/bin/env sh
# kodx dotfiles
# Author: kodx <kodx.org>

: <<'INSTALL'
wget --hsts-file /dev/null --no-check-certificate -qO- https://raw.githubusercontent.com/kodx/dotfiles/master/.kodxsetup.sh | INSALL=1 sh
or
curl -fsSL https://raw.githubusercontent.com/kodx/dotfiles/master/.kodxsetup.sh | INSALL=1 sh
INSTALL


: <<'SETUP'
cd $HOME
git clone --bare https://github.com/kodx/dotfiles.git $HOME/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout -f
SETUP

: <<'INITIALSETUP'
mkdir $HOME/.dotfiles
git init --bare $HOME/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no
dotfiles remote add origin https://github.com/kodx/dotfiles.git
dotfiles add .bashrc
dotfiles status
dotfiles commit -m "initial commit"
git push -u origin master
INITIALSETUP

: <<'USAGE'
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles add .profile
dotfiles status
dotfiles commit -m "The commit"
dotfiles push
USAGE

usage() {
    local SPATH="$0"
    cat <<EOM
    kodx dotfiles setup
    Usage:

    install dotfiles and applications
    $ INSALL=1 $SPATH
    or
    $ $SPATH insall

    install dotfiles
    $ INSDOTFILES=1 $SPATH
    or
    $ $SPATH insdotfiles

    install apps
    $ INSAPPS=1 $SPATH
    or
    $ $SPATH insapps
EOM
}

if [ "$#" -eq 0 ] && [ ! $INSDOTFILES ] && [ ! $INSAPPS ] && [ ! $INSALL ] ; then
    usage
    unset usage
    return
fi

insdotfiles() {
    cd $HOME
    git clone --bare https://github.com/kodx/dotfiles.git $HOME/.dotfiles
    alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    dotfiles config --local status.showUntrackedFiles no
    dotfiles checkout -f
    echo 'dotfiles install complete'
    return 0
}

getapp() {
    if [ "$#" -lt 2 ]; then
        return
    fi
    local GETOPT=''
    if [ "$1" = 'curl' ]; then
        GETOPT='-#L -o'
    else
        GETOPT='--hsts-file /dev/null -nv -O'
    fi
    local BINPATH="$HOME/bin/$(basename $2)"
    echo "downloading $2"
    $1 $2 $GETOPT $BINPATH
    chmod u+rx $BINPATH
}

insapps() {
    local GETCMD=$(if $(command -v 'curl' > /dev/null); then echo 'curl'; elif $(command -v 'wget' > /dev/null); then echo 'wget'; else echo ''; fi)
    if [ -z $GETCMD ]; then
        echo 'curl or wget not found, exit'
        return
    fi
    # set urls to apps
    local APPSARR="\
        https://yt-dl.org/downloads/latest/youtube-dl \
        https://raw.githubusercontent.com/kodx/lightsOn/master/lightsOn.sh"
    echo $APPSARR | tr ' ' '\n' | while read item; do getapp $GETCMD $item; done
    echo 'applications install complete'
    return 0
}

if [ $INSALL ] || $(test "$1" = 'insall'); then
    insdotfiles 
    insapps
else 
    [ $INSDOTFILES ] || [ "$1" = 'insdotfiles' ] && insdotfiles
    [ $INSAPPS ] || [ "$1" = 'insapps' ] && insapps
fi

unset insdotfiles insapps usage getapp
