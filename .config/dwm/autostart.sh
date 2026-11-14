#!/usr/bin/env sh
# SPDX-License-Identifier: GPL-3.0-or-later

start-pulseaudio-x11
#urxvtcd &
# urxvtd -q -f -o && urxvtc -e tab$HOME "mc -d && $SHELL"&
urxvtd -q -f -o && urxvtc -e tab$HOME $SHELL -ic "mc && $SHELL" tab$HOME $SHELL -ic "sleep 3s && mc && $SHELL" tab$HOME $SHELL -ic "sleep 3s && mc && $SHELL" tab$HOME $SHELL -i&


