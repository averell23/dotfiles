#!/bin/zsh

autoload colors
colors

# ----------------------------------------------------------------------
# various git scripts

gitize() {
        git init \
        && git add . \
        && git commit -a -m"initial commit" \
        && git gc
}

# ----------------------------------------------------------------------
# The following implements a caching mechanism for git information.
# The RPROMPT executes get_git_bprompt_info() and include the output...
#
#   setopt prompt_subst
#   RPROMPT="$(get_git_prompt_info)"
#
export __ZSH_GIT_DIR=
export __ZSH_GIT_BRANCH=
export __ZSH_GIT_STATE=
export __ZSH_GIT_VARS_INVALID=1

# get the name of the branch we are on
parse_git_branch() {
        git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) -- /'
}

# http://blog.madism.org/index.php/2008/05/07/173-git-prompt
new_parse_git_branch() {
    local git_dir branch

    psvar=()
    git_dir=$(git rev-parse --git-dir 2> /dev/null) || return

    # rewritten by Thomas Ritz <thomas(at)galaxy-ritz(dot)de>
    if test -d "$git_dir/rebase-apply"; then
            if test -f "$git_dir/rebase-apply/rebasing"; then
                    __ZSH_GIT_STATE="rebase"
            elif test -f "$git_dir/rebase-apply/applying"; then
                    __ZSH_GIT_STATE="am"
            else
                    __ZSH_GIT_STATE="am/rebase"
            fi
            branch="$(git symbolic-ref HEAD 2>/dev/null)"
    elif test -f "$git_dir/rebase-merge/interactive"; then
            __ZSH_GIT_STATE="rebase -i"
            branch="$(cat "$git_dir/rebase-merge/head-name")"
    elif test -d "$git_dir/rebase-merge"; then           
            __ZSH_GIT_STATE="rebase -m"
            branch="$(cat "$git_dir/rebase-merge/head-name")"
    elif test -f "$git_dir/MERGE_HEAD"; then             
            __ZSH_GIT_STATE="merge"
            branch="$(git symbolic-ref HEAD 2>/dev/null)"
    else                                             
            test -f "$git_dir/BISECT_LOG" && __ZSH_GIT_STATE="bisect"
            branch="$(git symbolic-ref HEAD 2>/dev/null)" || \
            branch="$(git describe --exact-match HEAD 2>/dev/null)" || \
            branch="$(cut -c1-7 "$git_dir/HEAD")..."
    fi                                              

    __ZSH_GIT_FULL_DIR=$(realpath ${git_dir:h})
    __ZSH_GIT_DIR="${__ZSH_GIT_FULL_DIR/$HOME/~}"
    __ZSH_GIT_BRANCH="${branch#refs/heads/}"

    export __ZSH_GIT_FULL_DIR
    export __ZSH_GIT_DIR
    export __ZSH_GIT_BRANCH
    export __ZSH_GIT_STATE
    export __ZSH_GIT_VARS_INVALID=
}


zsh_git_invalidate_vars() {
        export __ZSH_GIT_VARS_INVALID=1
}
zsh_git_compute_vars() {
        new_parse_git_branch
}

# on each chdir update the cached git variable(s)
preexec_functions+='zsh_git_preexec_update_vars'
chpwd_functions+='zsh_git_chpwd_update_vars'
#precmd_functions+='zsh_git_precmd_update_vars'

zsh_git_chpwd_update_vars() {
        zsh_git_invalidate_vars
}
zsh_git_preexec_update_vars() {
        case "$(history $HISTCMD)" in 
                *git*) zsh_git_invalidate_vars ;;
        esac
}

# this function returns the current git branch
# it takes as argument a string with printf like arguments:
#   '%P'     path to top of repository
#   '%p'     path to top of repository, with s/$HOME/~/
#   '%b'     current branch
#   '%s'     state of rebase/merge/bisect/am
#   '%%'     a '%' character
# providing no arguments is equivalent to "%p %b %s".
get_git_prompt_info() {
        test -n "$__ZSH_GIT_VARS_INVALID" && zsh_git_compute_vars
        test -n "$__ZSH_GIT_DIR" || return

        local def fmt res
        def='%p %b %s'
        fmt=$@
        res=${fmt:-$def}
        res=${res//\%P/$__ZSH_GIT_FULL_DIR }
        res=${res//\%p/$__ZSH_GIT_DIR }
        res=${res//\%b/$__ZSH_GIT_BRANCH }

        local state="$__ZSH_GIT_STATE"
        if test -n "$state" ; then
                state="$state "
#
# NOTE: This code take a long time to execute on large repos,
#       but can show if the repo is dirty or not.  It cannot be 
#       cached because it's too hard to figure out which commands
#       change this state.  Enable it if you work on only small
#       repositories.
#
        #elif ! git diff --quiet ; then
        #        state="dirty "
        fi
        res=${res//\%s/$state}

        res=${res//\%%/%}
        
        echo -n "${res}"
}

