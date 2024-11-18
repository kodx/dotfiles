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

if [ -f "$HOME"/.local/bin/git-prompt.sh ]; then
    source "$HOME"/.local/bin/git-prompt.sh
    use_git_prompt=$($(command -v '__git_ps1' > /dev/null) && echo 'yes' || echo 'no')
fi

if [ "$use_git_prompt" = yes ]; then
    GIT_PS1_SHOWCOLORHINTS='yes'
    GIT_PS1_SHOWDIRTYSTATE='yes'
    PROMPT_COMMAND='__git_ps1 "\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;96m\]\w\[\033[00m\]" "\\\$ " " \[\033[01;35m\][\[\033[00m\]%s\[\033[01;35m\]]\[\033[00m\]"'
else
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

#PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

unset use_git_prompt

if [ -f "$HOME/.config/aliases" ]; then
    . "$HOME/.config/aliases"
fi

if [ -n "$DISPLAY" ]; then
  xset b off
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

