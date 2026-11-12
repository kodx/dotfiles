# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck shell=sh
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# Author: kodx <kodx.org>

# shell variables
# shellcheck source=/dev/null
[ -f "$HOME/.config/envars" ] && . "$HOME/.config/envars"

# shell aliases if shell is interactive
case $- in
    *i*)
        # bash loads aliases from .bashrc below
        if [ -z "$BASH_VERSION" ] && [ -f "$HOME/.config/aliases" ]; then
            # shellcheck source=/dev/null
            . "$HOME/.config/aliases"
        fi
        ;;
esac

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    # shellcheck source=/dev/null
    [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
fi

# Start graphical server if i3 not already running.
# [ "$(tty)" = "/dev/tty1" ] && ! pgrep -x i3 >/dev/null && exec startx
