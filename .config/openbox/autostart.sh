tint2 &
#compton -CGb --backend glx --vsync &
#picom -b
#start-pulseaudio-x11
xsettingsd &
xset r rate 300 35      # Speed xrate up
xset -b
dunst &                 # dunst for notifications
sxhkd &
gxkb &
feh --randomize --no-fehbg --bg-fill ~/download/yadisk/pictures/wallpaper/nature2/
setxkbmap -layout us,ru -variant ,winkeys -option grp:alt_space_toggle,ctrl:nocaps # set keyboard layout
#$HOME/bin/autostart/K50lightsOn.sh
xset dpms 600 600 600
urxvtd -q -f -o && urxvtc -e tab$HOME $SHELL -ic "mc && $SHELL" tab$HOME $SHELL -ic "sleep 3s && mc && $SHELL" tab$HOME $SHELL -ic "sleep 3s && mc && $SHELL" tab$HOME $SHELL -i&
sleep 3s && firefox &
$HOME/work/programs/Telegram/Telegram &
yandex-disk start &

