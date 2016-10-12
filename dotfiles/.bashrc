#!/bin/sh
#
# Scott Krulcik
#
# Partially derived from CMU's bashrc_gpi and the linux example found in
# /usr/share/doc/bash/examples/startup-files
#
# To use on Mac, put `source ~/.bashrc` in the .bash_profile file
#

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# === Appearance ===
alias grep='grep --color=auto'

# === Prompt ===
force_color_prompt=yes
long_promp_path=

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi
if [ "$color_prompt" = yes ]; then
    if [ "$long_promp_path" = yes ]; then
        # Long path, no host:
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        # Long path, with host:
        #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    else
        # Short path, no host:
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
        # Short path, with host:
        # PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
    fi
else
    PS1='${debian_chroot:+($debian_chroot)}\u:\W\$ '
    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
    xterm*|rxvt*)
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
            ;;
        *)
            ;;
    esac
fi
unset color_prompt force_color_prompt


shopt -s checkwinsize         # Update window size after each command

## History configuration
export HISTCONTROL=ignoreboth # Don't store duplicates
shopt -s histappend           # Append only to history

#Remove case sensitive completion
if [ -f /etc/bash_completion ]; then
     . /etc/bash_completion
fi
bind "set completion-ignore-case on"


## Open shell to last cd
if [ -e ~/.last_cd ]
then
    cd "$(cat ~/.last_cd)"
fi
logged_cd() {
    cd "$@"
    pwd > ~/.last_cd
}
alias cd="logged_cd" # Keep track of most recent directory

## Useful aliases
alias ccomp='gcc -Wall -Wextra -Werror -std=c99 -pedantic'
alias valgrind-leak='valgrind --leak-check=full --show-reachable=yes'
alias hidden='ls -a | grep "^\..*"'
alias linelength='wc -L'
alias v='vim -p'

# Git Aliases
alias ga='git add'
alias gc='git commit'
alias gl='git log --graph --color --pretty=oneline -n 20 --abbrev-commit'
alias gla='git log --graph --color --pretty=format:"%C(yellow)%H%C(green)%d%C(reset)%n%x20%cd%n%x20%cn%x20(%ce)%n%x20%s%n" --stat'
alias gs='git status -s'
alias gsa='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias gpr='git pull --rebase'
# `gdi $number` shows the diff between the state `$number` revisions ago and the current state
alias gdi='d() { git diff --patch-with-stat HEAD~$1; }; git diff-index --quiet HEAD -- || clear; d'
alias grbc='git rebase --continue'
grbi() { git rebase -i HEAD~$1; }

# Makes a directory, then moves into it
mkcd() { mkdir -p "$@" && cd "$_"; }


## Mac-specific changes
if [[ `uname` = "Darwin" || `uname` = "FreeBSD" ]]
then
  # Colored ls
  alias ls='ls -G'

  # Scripts directory on my Macbook
  export PATH=/Applications/ShellScripts:$PATH

  # Homebrew settings
  export PATH=/usr/local/bin:$PATH
  export PYTHONPATH=/usr/local/lib/python2.7/site-packages:$PYTHONPATH

  alias vim='/usr/local/bin/vim'
  # Start up ssh-agent
  [[ -z $SSH_AGENT_PID && -z $DISPLAY ]] &&
    exec -l ssh-agent $SHELL -c "bash --login"
else
  alias ls='ls --color=auto'
  # Linux shutdown command (works on RasPi, haven't tested on others)
  alias shutdown="sudo shutdown -h now"
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi


gpi_makemake() {
    supported_extensions='tex java c c0'
	found=0
    for ext in $supported_extensions; do
        files=$(ls *.$ext 2> /dev/null | wc -l)
        if [ "$files" != "0" ]; then
			found=1
            break
        fi
    done
	if [ "$found" == "0" ]; then
		echo -e "You don't have any of the supported file types in this directory"
		return
	fi


    if [ "$ext" == "tex" ]; then
        echo -e "gpi_makemake is making you a LaTeX Makefile!"
        if [ "$files" == "1" ]; then
            file=$(echo *.${ext})
        else
            echo -e "There is more than one LaTeX file in your directory..."
            echo -e "Choose one from the list to be the main source file."
            select file in *.$ext; do break; done
        fi

        if [ "$file" == "" ]; then
            echo -e "Aborting..."
        else
            cat ${GPI_PATH}/makefiles/latex.mk |
                sed -e "s/GPIMAKEMAKE/${file%.tex}/" > Makefile
            echo "gpi_makemake has installed a LaTeX Makefile for $file"
            echo "${c_green}make${c_reset} -- Compiles the LaTeX document into a PDF"
            echo "${c_green}make clean${c_reset} -- Removes aux and log files"
            echo "${c_green}make veryclean${c_reset} -- Removes pdf, aux, and log files"
            echo "${c_green}make view${c_reset} -- Display the generated PDF file"
            echo "${c_green}make print${c_reset} -- Sends the PDF to print"
        fi
    elif [ "$ext" == "java" ]; then
        echo "gpi_makemake doesn't support java yet.  We will add it soon!"
    elif [ "$ext" == "c" ]; then
        echo -e "gpi_makemake is making you a C Makefile!"
        echo -n "What should the name of the target executable be? "
        read target

        cat ${GPI_PATH}/makefiles/c.mk |
            sed -e "s/GPIMAKEMAKE_TARGET/${target}/" > Makefile
        echo "gpi_makemake has installed a C Makefile!"
        echo "${c_green}make${c_reset} -- Compiles the C Program (no debug information)"
        echo "${c_green}make debug${c_reset} -- Compiles the C Program (with debugging information!)"
        echo "${c_green}make run${c_reset} -- Re-compiles (if necessary) and run the program"
        echo "${c_green}make clean${c_reset} -- Deletes the created object files"
        echo "${c_green}make veryclean${c_reset} -- Deletes the created object files and dependencies"
    elif [ "$ext" == "c0" ]; then
        echo -e "gpi_makemake is making you a C0 Makefile!"
        echo -n "List the C0 source files separated by spaces: "
        read sources
        echo -n "What should the name of the target executable be? "
        read target
 cat ${GPI_PATH}/makefiles/c0.mk |
            sed -e "s/GPIMAKEMAKE_TARGET/${target}/" |
            sed -e "s/GPIMAKEMAKE_SOURCE/${sources}/" > Makefile
        echo "gpi_makemake has installed a C0 Makefile"
        echo "${c_green}make${c_reset} -- Compiles the C0 Program (no debug information)"
        echo "${c_green}make debug${c_reset} -- Compiles the C0 Program (with debugging information!)"
        echo "${c_green}make run${c_reset} -- Re-compiles (if necessary) and run the program"
        echo "${c_green}make clean${c_reset} -- Deletes the created object files"
        echo "${c_green}make veryclean${c_reset} -- Deletes the created object files and dependencies"

    fi
}

# Suggested by jez
vman() {
    vim -c "SuperMan $*"

    if [ "$?" != "0" ]; then
        echo "No manual entry for $*"
    fi
}

# Open a tmux session if it doesn't exist, named after a similar script for
# CITC clients I used at Google
gmux() {
    if [ -z "$1" ]
    then
        echo 'Usage: gmux <session name>'
    else
        tmux attach-session -dt $1 || tmux new -s $1
    fi
}

# Fuzzy find bash history
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

