# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# Author: kodx <kodx.org>

# shell variables
[ -f "$HOME/.config/shvars" ] && . "$HOME/.config/shvars"

# shell aliases is shell is interactive
case $- in
    *i*)
        [ -f "$HOME/.config/aliases" ] && . "$HOME/.config/aliases"
        ;;
esac

# Start graphical server if i3 not already running.
# [ "$(tty)" = "/dev/tty1" ] && ! pgrep -x i3 >/dev/null && exec startx

