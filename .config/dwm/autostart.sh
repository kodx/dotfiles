#!/usr/bin/env sh

start-pulseaudio-x11
#urxvtcd &
# urxvtd -q -f -o && urxvtc -e tab$HOME "mc -d && $SHELL"&
urxvtd -q -f -o && urxvtc -e tab$HOME $SHELL -ic "mc && $SHELL" tab$HOME $SHELL -ic "sleep 3s && mc && $SHELL" tab$HOME $SHELL -ic "sleep 3s && mc && $SHELL" tab$HOME $SHELL -i&


