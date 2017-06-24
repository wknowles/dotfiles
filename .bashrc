#   Change Prompt
#   ---------------------------------------------------------------------------
    export PS1="\[$(tput bold)\]\[\033[38;5;10m\]\w\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \$(git_prompt) \n\[$(tput bold)\]\\$ \[$(tput sgr0)\]"

#   Add color to terminal
#   ---------------------------------------------------------------------------
    export CLICOLOR=1
    #export LSCOLORS=ExFxBxDxCxegedabagacad
    export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

#    Tell grep to highlight matches
#   ---------------------------------------------------------------------------
    export GREP_OPTIONS='--color=auto'

#   Set Paths
#   ---------------------------------------------------------------------------
    export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin"
    export PATH="$PATH:/Library/Frameworks/GDAL.framework/Programs"
    export PATH="$PATH:/Users/will/.scripts"
    export MYSQL_PATH=/usr/local/Cellar/mysql/5.7.17
    export PATH=$PATH:$MYSQL_PATH/bin

#   rbenv
#   ---------------------------------------------------------------------------
    eval "$(rbenv init -)"

#   private configs - not in git / dotfiles
#   ---------------------------------------------------------------------------
    if [ -r ~/.private.conf ]
    then
        source ~/.private.conf
    fi

#   Set Bash Completion and include completion features
#   ---------------------------------------------------------------------------
    if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
      . $(brew --prefix)/share/bash-completion/bash_completion
    fi

    # Case-insensitive globbing (used in pathname expansion)
    shopt -s nocaseglob

    # Ignore case while completing
    set completion-ignore-case on

    # Autocorrect typos in path names when using `cd`
    shopt -s cdspell

    # Enable some Bash 4 features when possible:
    # * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
    # * Recursive globbing, e.g. `echo **/*.txt`
    for option in autocd globstar; do
        shopt -s "$option" 2> /dev/null;
    done;

    # Add tab completion for SSH hosts based on ~/.ssh/config, ignore wildcards
    [ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

#   Do not record duplicate commnands to bash history
#   ---------------------------------------------------------------------------
    export HISTCONTROL=ignoreboth:erasedups

  # append history entries..
    shopt -s histappend

  # After each command, save and reload history
    export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

#   Git
#   ---------------------------------------------------------------------------
    # Git completion
    source /usr/local/etc/bash_completion.d/git-completion.bash

    git_branch() {
        # -- Finds and outputs the current branch name by parsing the list of
        #    all branches
        # -- Current branch is identified by an asterisk at the beginning
        # -- If not in a Git repository, error message goes to /dev/null and
        #    no output is produced
        git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
    }

    git_status() {
        # Outputs a series of indicators based on the status of the
        # working directory:
        # + changes are staged and ready to commit
        # ! unstaged changes are present
        # ? untracked files are present
        # S changes have been stashed
        # P local commits need to be pushed to the remote
        local status="$(git status --porcelain 2>/dev/null)"
        local output=''
        [[ -n $(egrep '^[MADRC]' <<<"$status") ]] && output="$output+"
        [[ -n $(egrep '^.[MD]' <<<"$status") ]] && output="$output!"
        [[ -n $(egrep '^\?\?' <<<"$status") ]] && output="$output?"
        [[ -n $(git stash list) ]] && output="${output}S"
        [[ -n $(git log --branches --not --remotes) ]] && output="${output}P"
        [[ -n $output ]] && output="|$output"  # separate from branch name
        echo $output
    }

    git_color() {
        # Receives output of git_status as argument; produces appropriate color
        # code based on status of working directory:
        # - White if everything is clean
        # - Green if all changes are staged
        # - Red if there are uncommitted changes with nothing staged
        # - Yellow if there are both staged and unstaged changes
        local staged=$([[ $1 =~ \+ ]] && echo yes)
        local dirty=$([[ $1 =~ [!\?] ]] && echo yes)
        if [[ -n $staged ]] && [[ -n $dirty ]]; then
            echo -e '\033[1;33m'  # bold yellow
        elif [[ -n $staged ]]; then
            echo -e '\033[1;32m'  # bold green
        elif [[ -n $dirty ]]; then
            echo -e '\033[1;31m'  # bold red
        else
            echo -e '\033[1;37m'  # bold white
        fi
    }

    git_prompt() {
        # First, get the branch name...
        local branch=$(git_branch)
        # Empty output? Then we're not in a Git repository, so bypass the rest
        # of the function, producing no output
        if [[ -n $branch ]]; then
            local state=$(git_status)
            local color=$(git_color $state)
            # Now output the actual code to insert the branch and status
            echo -e "\x01$color\x02[$branch$state]\x01\033[00m\x02"  # last bit resets color
        fi
    }

function_exists() {
    declare -f -F $1 > /dev/null
    return $?
}

for al in `__git_aliases`; do
    alias g$al="git $al"

    complete_func=_git_$(__git_aliased_command $al)
    function_exists $complete_fnc && __git_complete g$al $complete_func
done

#   Set Default Editor (set to sublime text)
#   ---------------------------------------------------------------------------
    export EDITOR='subl -w'

#   Set default blocksize for ls, df, du
#   from this: http://hints.macworld.com/comment.php?mode=view&cid=24491
#   ---------------------------------------------------------------------------
    export BLOCKSIZE=1k

#   MAKE TERMINAL BETTER
#   ---------------------------------------------------------------------------
    alias cp='cp -iv'                           # Pref 'cp' implementation
    alias mv='mv -iv'                           # Pref 'mv' implementation
    alias mkdir='mkdir -pv'                     # Pref 'mkdir' implementation
    alias ll='ls -FGlAhp'                       # Pref 'ls' implementation
    alias less='less -FSRXc'                    # Pref 'less' implementation
    cd() { builtin cd "$@"; ll; }               # Always list directory contents upon 'cd'
    alias cd..='cd ../'                         # Go back 1 directory level (for fast typers)
    alias ..='cd ../'                           # Go back 1 directory level
    alias ...='cd ../../'                       # Go back 2 directory levels
    alias .3='cd ../../../'                     # Go back 3 directory levels
    alias .4='cd ../../../../'                  # Go back 4 directory levels
    alias .5='cd ../../../../../'               # Go back 5 directory levels
    alias .6='cd ../../../../../../'            # Go back 6 directory levels
    alias f='open -a Finder ./'                 # f:            Opens current directory in MacOS Finder
    alias ~="cd ~"                              # ~:            Go Home
    alias c='clear'                             # c:            Clear terminal display
    alias which='type -all'                     # which:        Find executables
    alias path='echo -e ${PATH//:/\\n}'         # path:         Echo all executable Paths
    alias show_options='shopt'                  # Show_options: display bash options settings
    mcd () { mkdir -p "$1" && cd "$1"; }        # mcd:          Makes new Dir and jumps inside
    trash () { command mv "$@" ~/.Trash ; }     # trash:        Moves a file to the MacOS trash
    ql () { qlmanage -p "$*" >& /dev/null; }    # ql:           Opens any file in MacOS Quicklook Preview
    alias DT='tee ~/Desktop/terminalOut.txt'    # DT:           Pipe content to file on MacOS Desktop

#   FILE AND FOLDER MANAGEMENT
#   ---------------------------------------------------------------------------
    zipf () { zip -r "$1".zip "$1" ; }          # zipf:         To create a ZIP archive of a folder
    alias numFiles='echo $(ls -1 | wc -l)'      # numFiles:     Count of non-hidden files in current dir

#   cdf:  'Cd's to frontmost window of MacOS Finder
#   ---------------------------------------------------------------------------
    cdf () {
        currFolderPath=$( /usr/bin/osascript <<EOT
            tell application "Finder"
                try
            set currFolder to (folder of the front window as alias)
                on error
            set currFolder to (path to desktop folder as alias)
                end try
                POSIX path of currFolder
            end tell
EOT
        )
        echo "cd to \"$currFolderPath\""
        cd "$currFolderPath"
    }

#   SEARCHING
#   ---------------------------------------------------------------------------
    alias qfind="find . -name "                 # qfind:    Quickly search for file
    ff () { /usr/bin/find . -name "$@" ; }      # ff:       Find file under the current directory
    ffs () { /usr/bin/find . -name "$@"'*' ; }  # ffs:      Find file whose name starts with a given string
    ffe () { /usr/bin/find . -name '*'"$@" ; }  # ffe:      Find file whose name ends with a given string

#   spotlight: Search for a file using MacOS Spotlight's metadata
#   ---------------------------------------------------------------------------
    spotlight () { mdfind "kMDItemDisplayName == '$@'wc"; }

#   Show / Hide hidden files in Finder
#   ---------------------------------------------------------------------------
    alias finderShowHidden='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
    alias finderHideHidden='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'

#   mirror: use wget to mirror website. mirror(wait time, url)
#   ---------------------------------------------------------------------------
    mirror () { wget --mirror --convert-links --adjust-extension --page-requisites --no-parent -w $1 $2; }

#   anybar: setup alias
#   ---------------------------------------------------------------------------
    function anybar { echo -n $1 | nc -4u -w0 localhost ${2:-1738}; }

#   ---------------------------------------------------------------------------
#   Misc Alias'
#   ---------------------------------------------------------------------------
    alias bashrc='subl $HOME/Documents/github/dotfiles/.bashrc'
    alias backup='rsync -PhaEiz --stats '
    alias editHosts='sudo subl /etc/hosts'
    alias flushdns='sudo killall -HUP mDNSResponder'
    alias startjambo='sshuttle --dns --pidfile=/tmp/sshuttle.pid -Dr jambohouse 0/0'
    alias startkidani='sshuttle --dns --pidfile=/tmp/sshuttle.pid -Dr kidanivillage 0/0'
    alias startckd='sshuttle --dns --pidfile=/tmp/sshuttle.pid -Dr server@81.138.8.156 0/0'
    alias stopsshuttle='[[ -f /tmp/sshuttle.pid ]] && sudo kill $(cat /tmp/sshuttle.pid) && echo "Disconnected."'
    alias weather='curl wttr.in'
    alias whatip='curl https://icanhazip.com'
