# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Author: kodx <kodx.org>

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=2000

# History with timestamp
HISTTIMEFORMAT="%t%d.%m.%y %H:%M:%S%t"
# HISTIGNORE="&:ls:[bf]g:exit: cd \"\`*: PROMPT_COMMAND='*"
HISTIGNORE=${HISTIGNORE:-"&:ls:[bf]g:exit: cd \"\`*: PROMPT_COMMAND='*:shutdown*:halt*:poweroff*:hibernate*:rm -rf*"}

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# Allows you to cd into directory merely by typing the directory name.
shopt -s autocd 

# When the command contains an invalid history operation (for instance when
# using an unescaped "!" (I get that a lot in quick e-mails and commit
# messages) or a failed substitution (e.g. "^foo^bar" when there was no "foo"
# in the previous command line), do not throw away the command line, but let me
# correct it.
shopt -s histreedit

# check if the user isn't root
if [ "$UID" != 0 ]; then
    # case-insensitive globbing (used in pathname expansion)
    shopt -s nocaseglob

    # autocorrect typos in path names when using `cd`
    shopt -s cdspell
fi

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    if [[ "$WINDOW" == "" ]]; then
        export PROMPT="%n:%~> "
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w> '
    else
        export PROMPT="%n($WINDOW):%~> "
        PS1='${debian_chroot:+($debian_chroot)}\u@\h($WINDOW):\w> '
    fi
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
#esac

if [ -f "$HOME/.config/aliases" ]; then
    . "$HOME/.config/aliases"
fi

