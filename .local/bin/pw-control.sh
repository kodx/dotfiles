#!/usr/bin/env sh
# Author: Yegor Bayev <kodx.org>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Settings
VOLSTEP=2%
# set ports
# change to your ports
# list available ports using CMD 'list-port'
OUTLINE='analog-output-lineout'
OUTPHONES='analog-output-headphones'

if [ $# -eq 0 ] || [ $# -gt 2 ]; then
    echo "Usage: $(basename "$0") [CMD]"
    echo 'helper script to control pipewire via pactl'
    echo ''
    echo 'where CMD:'
    printf '%b\n' 'plus\t\tincrease sound volume'
    printf '%b\n' 'minus\t\tdecrease sound volume'
    printf '%b\n' 'mute\t\tdefault output mute toggle'
    printf '%b\n' 'mic-mute\tdefault input mute toggle'
    printf '%b\n' 'mic-mute 1\tmute default input'
    printf '%b\n' 'mic-mute 0\tunmute default input'
    printf '%b\n' 'swport\t\tswitch port from lineout to headphones and vice versa'
    printf '%b\n' 'list-ports\tlist available ports of default output'
    echo ''
    echo 'Examples:'
    printf '%b\n' '# add sound volume'
    printf '%b\n' "$(basename "$0") plus"
    echo ''
    printf '%b\n' '# switch port'
    printf '%b\n' "$(basename "$0") swport"
    echo ''
    printf '%b\n' '# toggle microphone mute'
    printf '%b\n' "$(basename "$0") mic-mute"
    exit 1;
fi

getport() {
    activeport=$(pactl list sinks | awk -v apvar="Name: $(pactl get-default-sink)" 'index($0, apvar),/Active Port:/ {print}' | awk '/Active Port:/ { print $3 }')
    if [ $activeport = "$OUTLINE" ]; then
        echo $OUTPHONES
    else 
        echo $OUTLINE
    fi
}

case "$1" in
    plus)
        pactl set-sink-volume @DEFAULT_SINK@ +$VOLSTEP > /dev/null 2>&1
    ;;
    minus)
        pactl set-sink-volume @DEFAULT_SINK@ -$VOLSTEP > /dev/null 2>&1
    ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle > /dev/null 2>&1
    ;;
    swport)
        pactl set-sink-port @DEFAULT_SINK@ "$(getport)" > /dev/null 2>&1
    ;;
    mic-mute)
        pactl set-source-mute @DEFAULT_SOURCE@ ${2:-'toggle'}
    ;;
    list-ports)
        pactl list sinks | awk -v apvar="Name: $(pactl get-default-sink)" 'index($0, apvar),/Active Port:/ {print}' | awk '/Active Port:/{exit} f; /Ports:/{f=1}' | awk '{$1=$1};1'
esac

