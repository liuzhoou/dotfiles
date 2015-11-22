# If not running interactively, don't do anything

[ -z "$PS1" ] && return

## path
export PATH=/usr/local/bin:/usr/local/sbin:${PATH}

## java_home
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home

## Sphinx
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

## TextMate
export EDITOR='mate'
export GIT_EDITOR='mate -wl1'

## History control
export HISTCONTROL=ignoreboth
shopt -s histappend

## android
export ANDROID_SDK=/Applications/adt-bundle-mac-x86_64-20130729/sdk
export ANDROID_NDK=/Applications/adt-bundle-mac-x86_64-20130729/ndk
export ANDROID_HOME=/Applications/adt-bundle-mac-x86_64-20130729/sdk
export PATH=$PATH:${JAVA_HOME}/bin:${ANDROID_SDK}/platform-tools:${ANDROID_SDK}/tools:${ANDROID_NDK}

if [[ -n `which brew` ]]; then
  # Find a Homebrew-built Python
  python_bin=$(brew --cellar python)/*/bin
  python_bin=`echo $python_bin`
  [[ -e $python_bin ]] && export PATH=$python_bin:$PATH

  [[ -e /usr/local/share/python ]] && export PATH=/usr/local/share/python:$PATH

  # Find a Homebrew-built Ruby
  ruby_bin=$(brew --cellar ruby)/*/bin
  ruby_bin=`echo $ruby_bin`
  [[ -e $ruby_bin ]] && export PATH=$ruby_bin:$PATH
fi


# No ._ files in archives please
export COPYFILE_DISABLE=true


#  ls aliases
alias ll="ls -l -h"
alias la="ls -a"
alias l="ls -G"
alias lla="ls -a -l"
alias lm='ls -la | less'

## Aliases
alias cls='clear'
alias delpyc="find . -name '*.pyc' -delete"
alias tree='find . -print | sed -e "s;[^/]*/;|____;g;s;____|; |;g"'
alias sizes='du -h -d1'

alias go-bundles="cd ~/Library/Application\ Support/TextMate/Bundles/"
alias go-themes="cd ~/Library/Application\ Support/TextMate/Themes/"

alias firefox-dev="~/Applications/Minefield.app/Contents/MacOS/firefox-bin -no-remote -P dev &"

alias flushdns="dscacheutil -flushcache"

alias pigs="du | sort -nr | cut -f2- | xargs du -hs"
alias pigs1="du -d1 | sort -nr | cut -f2- | xargs du -hs"

alias gh="gh-pick"

alias fhome="figit on -x 1600 -y 1000"
alias fwork="figit off"

function amacs
 {
     # Create the files as needed -- not as good as raw emacs, but acceptable
     for f in "$@"
     do
 	test -e $f || touch $f
     done
     open -a /Applications/Aquamacs.app "$@"
 }

function show-empty-folders {
    find . -depth -type d -empty
}

function kill-empty-folders {
    find . -depth -type d -empty -exec rmdir "{}" \;
}

## Tab Completions
set completion-ignore-case On

for comp in \
    /usr/local/etc/bash_completion \
    /usr/local/etc/bash_completion.d/git-completion.bash \
    ~/homebrew/Library/Contributions/brew_bash_completion.sh \
    ~/source/custom-django/extras/django_bash_completion
do
    [[ -e $comp ]] && source $comp
done

source ~/.dotfiles/completion_scripts/fab_completion.bash
source ~/.dotfiles/completion_scripts/pip_completion.bash


## Python stuff
export VIRTUALENV_USE_DISTRIBUTE
export WORKON_HOME=$HOME/env

export SCALA_HOME=$(brew --prefix scala)/libexec
export PATH=$SCALA_HOME:$PATH
# PYTHONPATH
export PYTHONPATH=/usr/local/lib/python2.7/site-packages:/Library/Python/2.7/site-packages:$PYTHONPATH


## Custom prompt
# Colors
       RED="\[\033[0;31m\]"
      PINK="\[\033[1;31m\]"
    YELLOW="\[\033[1;33m\]"
     GREEN="\[\033[0;32m\]"
  LT_GREEN="\[\033[1;32m\]"
      BLUE="\[\033[0;34m\]"
     WHITE="\[\033[1;37m\]"
    PURPLE="\[\033[1;35m\]"
      CYAN="\[\033[1;36m\]"
     BROWN="\[\033[0;33m\]"
COLOR_NONE="\[\033[0m\]"

LIGHTNING_BOLT="⚡"
      UP_ARROW="↑"
    DOWN_ARROW="↓"
      UD_ARROW="↕"
      FF_ARROW="→"
       RECYCLE="♺"
        MIDDOT="•"
     PLUSMINUS="±"


function parse_git_branch {
  branch_pattern="On branch ([^[:space:]]*)"
  remote_pattern_ahead="# Your branch is ahead of"
  remote_pattern_behind="# Your branch is behind"
  remote_pattern_ff="# Your branch (.*) can be fast-forwarded."
  diverge_pattern="# Your branch and (.*) have diverged"

  git_status="$(git status 2> /dev/null)"
  if [[ ! ${git_status} =~ ${branch_pattern} ]]; then
    # Rebasing?
    toplevel=$(git rev-parse --show-toplevel 2> /dev/null)
    [[ -z "$toplevel" ]] && return

    [[ -d "$toplevel/.git/rebase-merge" || -d "$toplevel/.git/rebase-apply" ]] && {
      sha_file="$toplevel/.git/rebase-merge/stopped-sha"
      [[ -e "$sha_file" ]] && {
        sha=`cat "${sha_file}"`
      }
      echo "${PINK}(rebase in progress)${COLOR_NONE} ${sha}"
    }
    return
  fi
  branch=${BASH_REMATCH[1]}

  # Dirty?
  if [[ ! ${git_status} =~ "working directory clean" ]]; then
    [[ ${git_status} =~ "modified:" ]] && {
      git_is_dirty="${RED}${LIGHTNING_BOLT}"
    }

    [[ ${git_status} =~ "Untracked files" ]] && {
      git_is_dirty="${git_is_dirty}${WHITE}${MIDDOT}"
    }

    [[ ${git_status} =~ "new file:" ]] && {
      git_is_dirty="${git_is_dirty}${LT_GREEN}+"
    }

    [[ ${git_status} =~ "deleted:" ]] && {
      git_is_dirty="${git_is_dirty}${RED}-"
    }

    [[ ${git_status} =~ "renamed:" ]] && {
      git_is_dirty="${git_is_dirty}${YELLOW}→"
    }
  fi

  # Are we ahead of, beind, or diverged from the remote?
  if [[ ${git_status} =~ ${remote_pattern_ahead} ]]; then
    remote="${YELLOW}${UP_ARROW}"
  elif [[ ${git_status} =~ ${remote_pattern_ff} ]]; then
    remote_ff="${WHITE}${FF_ARROW}"
  elif [[ ${git_status} =~ ${remote_pattern_behind} ]]; then
    remote="${YELLOW}${DOWN_ARROW}"
  elif [[ ${git_status} =~ ${diverge_pattern} ]]; then
    remote="${YELLOW}${UD_ARROW}"
  fi

  echo "${remote}${remote_ff}${GREEN}(${branch})${COLOR_NONE}${git_is_dirty}${COLOR_NONE}"
}

# SVN parse_svn_branch
function parse_svn_branch {
  if [ -d '.svn' ]; then
    ref="$(svn info | grep Root | awk -F/ '{print $NF}' 2> /dev/null)"
    svn_status="$(svn status 2> /dev/null)"
    if [[ ${svn_status} ]]; then
        svn_is_dirty="${RED}${LIGHTNING_BOLT}"
    fi
    echo "${GREEN}(${ref})${COLOR_NONE}${svn_is_dirty}${COLOR_NONE}"
  fi
}

function setWindowTitle {
  case $TERM in
    *xterm*|ansi)
      echo -n -e "\033]0;$*\007"
      ;;
  esac
}

function set_prompt {
  [[ -n $HOMEBREW_DEBUG_INSTALL ]] && \
    homebrew_prompt="${BROWN}Homebrew:${COLOR_NONE} debugging ${HOMEBREW_DEBUG_INSTALL}\n"

  git_prompt="$(parse_git_branch)"
  svn_prompt="$(parse_svn_branch)"

  export PS1="[\w] ${git_prompt}${svn_prompt}${COLOR_NONE}\n${homebrew_prompt}\$ "

  # Domain is stripped from hostname
  case $HOSTNAME in
    adamv-desktop.local|Flangymobile08.local)
      this_host=
      ;;
    *)
      this_host="${HOSTNAME%%.*}:"
      ;;
  esac

  setWindowTitle "${this_host}${PWD/$HOME/~}"
}
export PROMPT_COMMAND=set_prompt


function git-root {
  root=$(git rev-parse --git-dir 2> /dev/null)
  [[ -z "$root" ]] && root="."
  dirname $root
}


# Reveal current or provided folder in Path Finder
function pf {
  target_path="$(cd ${1:-"$PWD"} && PWD)"
  osascript<<END
tell app "Path Finder"
  reveal POSIX file("$target_path")
  activate
end tell
END
}

# Open a manpage in Preview, which can be saved to PDF
function pman {
   man -t "${1}" | open -f -a /Applications/Preview.app
}

# Open a manpage in the browser
function bman {
  man "${1}" | man2html | browser
}

function pgrep {
  local exclude="\.svn|\.git|\.swp|\.coverage|\.pyc|_build"
  find . -maxdepth 1 -mindepth 1 | egrep -v "$exclude" | xargs egrep -lir "$1" | egrep -v "$exclude" | xargs egrep -Hin --color "$1"
}

# cd to finder's front's window's path
function cdf() 
{
   cdfpath="`osascript -e 'tell application "Finder" to set myname to POSIX path of (target of window 1 as alias)' 2>/dev/null`"
   if [ -n "$cdfpath" ]; then
      echo "cd to $cdfpath"
      cd "$cdfpath"
   else
      echo "no finder window finded"
   fi
}
