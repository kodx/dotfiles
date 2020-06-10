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
        #cat "${MC_EXT_FILENAME}"
        ffmpeg -i "${MC_EXT_FILENAME}" 2>&1 | sed -n '/^Input/ { p; :a; n; p; ba; }' | grep -v "At least one output file must be specified"
        ;;
    esac
}

do_open_action() {
    filetype=$1

    case "${filetype}" in
    mod)
        mikmod "${MC_EXT_FILENAME}"
        #tracker "${MC_EXT_FILENAME}"
        ;;
    wav22)
        vplay -s 22 "${MC_EXT_FILENAME}"
        ;;
    midi)
        timidity "${MC_EXT_FILENAME}"
        ;;
    playlist)
        $player -vo null -playlist "${MC_EXT_FILENAME}"
        ;;
    *)
        $player -vo null "${MC_EXT_FILENAME}"
        ;;
    esac
}

case "${action}" in
view)
    do_view_action "${filetype}"
    ;;
open)
    # "${MC_XDG_OPEN}" "${MC_EXT_FILENAME}" 2>/dev/null || \
    # do_open_action "${filetype}" >/dev/null 2>&1 &
    do_open_action "${filetype}"
    ;;
*)
    ;;
esac
