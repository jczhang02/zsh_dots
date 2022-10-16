
## plugins/atuin.zsh
# Enable atuin history plugin
# Import atuin history into zsh array
# Support multiline commands
# Support interactive atuin, interactive fzf,
#   inline history navigation with or without fzf filtering by query
# Support zsh-autosuggestions using atuin history
# Support highlighting of query terms

export ATUIN_NOBIND="false"
eval "$(atuin init zsh)"

## Import atuin history into zsh array
declare -U _history_atuin # -U indicates unique array so duplicates are not inserted
# Get the last 1500 (More than the 'max_lenght' below, to account for duplicates) commands from the atuin history database
# Separate each command with ';;\n;;' instead of '\n', this allows support for multiline commands.
#  Split them using the same separator and insert them into the array: (@pws:;;\n;;:).
# Sort them by timestamp in descending order (Last executed command first), this helps with:
#   Limiting the number of sqlite rows (otherwise it woulds trim the latest rows)
#   As latest commands are inserted first they have preference to earlier ones when checking for duplicates.
#   Bonus points for simplifying 'Limit history array size' below.
_history_atuin=("${(@pws:;;\n;;:)"$(sqlite3 --newline $';;\n;;' ~/.local/share/atuin/history.db 'SELECT command FROM history ORDER BY timestamp DESC LIMIT 2000')"}")

# Redeclare as normal array, this allows us to store new duplicate commands for keeping a better session history.
# Ofc those duplicates get removed when opening a new terminal.
declare -a history_atuin

## Limit history array size to 1000
# _history_atuin:0:1000, Get slice from 0 to 1000, effectively trimming it's size
# (@Oa), Reverse the order so last executed commands are first
history_atuin=(${(@Oa)_history_atuin:0:1000})
unset _history_atuin

if [[ -z $history_atuin ]]; then
    echo 'Error: Atuin history array is empty'
    echo 'Atuin may not be installed, history not imported, wrong path for the database or something else.'
    exit
fi

## Keep history array updated with new executed commands
_atuin_update_history_preexec(){
    if [[ $history_atuin[-1] != "$1" ]]; then
        # Store the new command in history if it's different than the last one
        # This basically avoids adding duplicate commands one right after the other
        history_atuin+=("$1") # Store the command in our zsh array (cache)
    fi
}
add-zsh-hook preexec _atuin_update_history_preexec

## Set selected command as new buffer and move the cursor to the end
__atuin_set_buffer() {
    BUFFER="$1"
    CURSOR=${#BUFFER}
}

## Invoque fzf with atuin history
_atuin_fzf() {
    # Print history splitting commands with nulls `print -rNC1 -- $var`
    # Get the history inverted `${(@Oa)history_atuin}` for the print command.
    # Get and parse history using nulls as separators
    # Nulls are used as separators instead of newlines to keep support for multiline commands
    output=$(print -rNC1 -- "${(@Oa)history_atuin}" | fzf --read0)
    __atuin_set_buffer "$output"
}
zle -N _atuin_fzf

typeset -g _atuin_fzf_inline_query
typeset -g _atuin_fzf_inline_query_matches
typeset -g _atuin_fzf_inline_result
typeset -i _atuin_fzf_inline_result_index=0

## Emulate history-substring-search but with atuin results
__atuin_fzf_inline() {
    typeset -g suggestion=''
    local add_or_substract="$1"

    # Move the cursor instead of changing history command
    #  but only if he current command is multiline, and we are not in the first or last line
    #   (depending if we are moving up or downon the history)
    if (( $BUFFERLINES > 1 )); then
        local lines_before_end
        if [[ "$add_or_substract" == '+' ]]; then
            lines_before_end=(${(f)LBUFFER})
        else
            lines_before_end=(${(f)RBUFFER})
        fi
        if (( ${#lines_before_end} > 1 )); then
            if [[ "$add_or_substract" == '+' ]]; then
                zle up-line    # zsh builtin, move cursor one line up
            else
                zle down-line  # zsh builtin, move cursor one line down
            fi
            return
        fi
    fi

    # Add or substract one from the index, depending if we are going up or down on the history
    _atuin_fzf_inline_result_index=$(( _atuin_fzf_inline_result_index $add_or_substract 1 ))

    if (( _atuin_fzf_inline_result_index < 0 )); then
        # Drop the current query, clear the buffer.
        _atuin_fzf_inline_result_index=0
        unset _atuin_fzf_inline_query_matches
        __atuin_set_buffer ''
        return
    elif [[ "$BUFFER" == "$_atuin_fzf_inline_result" ]]; then
        if (( _atuin_fzf_inline_result_index == 0 )); then
            __atuin_set_buffer "$_atuin_fzf_inline_query"
            return
        fi
    else
        _atuin_fzf_inline_result_index=1
        unset _atuin_fzf_inline_query_matches
        _atuin_fzf_inline_query="$BUFFER"
    fi

    ## Get the history array we are gonna use
    local query="$_atuin_fzf_inline_query"
    local index="$_atuin_fzf_inline_result_index"
    if [[ -n "$query" ]]; then # Filter commands by query using fzf
        # Create array of matches, filtered by fzf if not already created
        #   Print history splitting commands with nulls `print -rNC1 -- $var`
        #   Filter results with fzf, using nulls as separators for both input and output
        #   Create array using nulls as separators `(@0)`
        # Nulls are used as separators instead of newlines to keep support for multiline commands
        if [[ -z "$_atuin_fzf_inline_query_matches" ]]; then
            _atuin_fzf_inline_query_matches=("${(@0)"$(print -rNC1 -- "$history_atuin[@]" | fzf --read0 --print0 --exact --no-sort --filter="$query")"}")
            shift -p _atuin_fzf_inline_query_matches # Pop the last item, it's an empty string
        fi
        matches='_atuin_fzf_inline_query_matches'
    else # No need to filter with fzf if there is no query, use the entire history array
        matches='history_atuin'
    fi

    max_index=${#${(P)matches}} # Get size of array named $matches
    if (( index > max_index )); then
        _atuin_fzf_inline_result_index="$max_index"
        # We already reached the end of the history, do nothing
        return
    fi

    ## Get next command from history
    # From array named $matches get element -$index, negative number to start from the last element
    _atuin_fzf_inline_result=${${(P)matches}[-$index]}

    ## Set command as current edit buffer
    __atuin_set_buffer "$_atuin_fzf_inline_result"

    # Find all matches of $query in $BUFFER and highlight them
    if [[ -n "$query" ]]; then
        _zsh_highlight # This needs to be before region_highlight+= or the added highlight will be ignored, does _zsh_highlight clear the region_highlight array?.
        local last_match_end=0
        while true; do
            # (i) Search $query inside $BUFFER and return the index of the first matching character
            # (e) Match using $query as a literal string (i.e. query=* will match the literal character `*`)
            # (b:last_match_end:) Start matching from index=$last_match_end
            local match_start="${BUFFER[(ieb:last_match_end:)${query}]}"
            if (( $match_start <= ${#BUFFER} )); then
                local match_end=$(( $match_start + ${#query} ))
                last_match_end=$match_end
                # Highlight from index $match_start to $match_end, they need an offset of 1
                region_highlight+=("$(($match_start - 1)) $(($match_end - 1)) underline") # bold
            else
                # The query didn't match anything
                break
            fi
        done
    fi
}

atuin_fzf_inline_up() {
    __atuin_fzf_inline '+'
}
atuin_fzf_inline_down() {
    __atuin_fzf_inline '-'
}

zle -N atuin_fzf_inline_up
zle -N atuin_fzf_inline_down

## Add compatibility with zsh-autosuggest

# Tell  autosuggest to clear suggestions when atuin changes the edit buffer


_zsh_autosuggest_strategy_atuin() {
  
    # Reset options to defaults and enable LOCAL_OPTIONS
    emulate -L zsh

    # Enable globbing flags so that we can use (#m) and (x~y) glob operator
    setopt EXTENDED_GLOB

    # Escape backslashes and all of the glob operators so we can use
    # this string as a pattern to search the $history associative array.
    # - (#m) globbing flag enables setting references for match data
    # TODO: Use (b) flag when we can drop support for zsh older than v5.0.8
    local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"

    # Get the history items that match the prefix, excluding those that match
    # the ignore pattern
    local pattern="$prefix*"
    if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]; then
        pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
    fi

    # Give the first history item matching the pattern as the suggestion
    # - (r) subscript flag makes the pattern match on values
    # - (R) same as r, but gives the last match
    typeset -g suggestion="${history_atuin[(R)$pattern]}"
}
