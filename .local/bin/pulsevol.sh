#!/usr/bin/env sh
# Author: Yegor Bayev <kodx.org>

# Settings
VOLSTEP=2%
# set ports
# use this command to show available ports:
# pacmd list-sinks | gawk '/* index:/{f=1;next} /index:/{f=0} f' | gawk '/ports:/{f=1;next} /active port:/{f=0} f'
# or
# pacmd list-sinks | sed '/* index:/,/index:/!d;/active port:/!d;s/^\s*.*:\s<\([a-z-]*\)>/\1/'
OUTLINE='analog-output-lineout'
OUTPHONES='analog-output-headphones'

if [ $# -ne 1 ] ; then
    echo "Usage: $(basename "$0") [CMD]"
    echo 'program to ease control of pulseaudio server'
    echo ''
    echo 'where CMD:'
    echo '\tplus\tincrease sound volume'
    echo '\tminus\tdecrease sound volume'
    echo '\tmute\ttoggle mute'
    echo '\tswport\tswitch port from lineout to headphones and vice versa'
    echo ''
    echo 'Examples:'
    echo '\t# add sound volume'
    echo "\t$(basename "$0") plus"
    echo ''
    echo '\t# switch port'
    echo "\t$(basename "$0") swport"
    exit 1;
fi

getport() {
    #activeport=$(pacmd list-sinks | awk '/* index:/{f=1;next} /index:/{f=0} f' | awk '/active port:/ { print $3 }' | tr -d '<>')
    activeport=$(pacmd list-sinks | sed '/* index:/,/index:/!d;/active port:/!d;s/^\s*.*:\s<\([a-z-]*\)>/\1/')
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
        pactl set-sink-port @DEFAULT_SINK@ $(getport) > /dev/null 2>&1
esac

