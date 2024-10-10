#!/bin/sh

# $1 - action
# $2 - type of file

action=$1
filetype=$2
player=mpv

[ -n "${MC_XDG_OPEN}" ] || MC_XDG_OPEN="xdg-open"

do_view_action() {
    filetype=$1

    case "${filetype}" in
    *)
        #mplayer -identify -vo null -ao null -frames 0 "${MC_EXT_FILENAME}" 2>&1 | \
            #sed -n 's/^ID_//p'
        ffmpeg -i "${MC_EXT_FILENAME}" 2>&1 | sed -n '/^Input/ { p; :a; n; p; ba; }' | grep -v "At least one output file must be specified"
        ;;
    esac
}

do_open_action() {
    filetype=$1

    case "${filetype}" in
    ram)
        (realplay "${MC_EXT_FILENAME}" &>/dev/null &)
        ;;
    *)
        if [ -n "$DISPLAY" ]; then
            ($player "${MC_EXT_FILENAME}" &>/dev/null &)
        else
            $player -vo null "${MC_EXT_FILENAME}"
        fi
        #(gtv "${MC_EXT_FILENAME}" >/dev/null 2>&1 &)
        #(xanim "${MC_EXT_FILENAME}" >/dev/null 2>&1 &)
        ;;
    esac
}

case "${action}" in
view)
    do_view_action "${filetype}"
    ;;
open)
    "${MC_XDG_OPEN}" "${MC_EXT_FILENAME}" &>/dev/null || \
        #do_open_action "${filetype}" >/dev/null 2>&1 &
        do_open_action "${filetype}" &
    ;;
*)
    ;;
esac
