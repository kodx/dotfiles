#!/usr/bin/env sh
# Author: kodx <kodx.org>

# xinitrc runs automatically when you run startx.
[ -f $HOME/.xprofile ] && . $HOME/.xprofile

exec $HOME/bin/dwm 

