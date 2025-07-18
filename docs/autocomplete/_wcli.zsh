#compdef wcli

_wcli () {
    declare -a literals=("-v" "--version" "--location" "--lang" "ar" "bn" "bg" "zh" "zh_tw" "cs" "da" "nl" "fi" "fr" "de" "el" "hi" "hu" "it" "ja" "jv" "ko" "zh_cmn" "mr" "pl" "pt" "pa" "ro" "ru" "sr" "si" "sk" "es" "sv" "ta" "te" "tr" "uk" "ur" "vi" "zh_wuu" "zh_hsn" "zh_yue" "zu" "--json" "-h" "--help" "--color" "auto" "never" "always")
    declare -A descrs=()
    descrs[0]="Prints the version and exits"
    descrs[1]="Specify the location"
    descrs[2]="Specify the language"
    descrs[3]="Print the json response and exit"
    descrs[4]="Show this help output."
    descrs[5]="When to use colors (*auto*, never, always)."
    declare -A descr_id_from_literal_id=([1]=0 [2]=0 [3]=1 [4]=2 [45]=3 [46]=4 [47]=4 [48]=5)
    declare -a regexes=()
    declare -A literal_transitions=()
    literal_transitions[1]="([1]=2 [2]=2 [3]=3 [4]=4 [45]=2 [46]=2 [47]=2 [48]=5)"
    literal_transitions[2]="([1]=2 [2]=2 [3]=3 [4]=4 [45]=2 [46]=2 [47]=2 [48]=5)"
    literal_transitions[4]="([5]=2 [6]=2 [7]=2 [8]=2 [9]=2 [10]=2 [11]=2 [12]=2 [13]=2 [14]=2 [15]=2 [16]=2 [17]=2 [18]=2 [19]=2 [20]=2 [21]=2 [22]=2 [23]=2 [24]=2 [25]=2 [26]=2 [27]=2 [28]=2 [29]=2 [30]=2 [31]=2 [32]=2 [33]=2 [34]=2 [35]=2 [36]=2 [37]=2 [38]=2 [39]=2 [40]=2 [41]=2 [42]=2 [43]=2 [44]=2)"
    literal_transitions[5]="([49]=2 [50]=2 [51]=2)"
    declare -A nontail_transitions=()
    declare -A match_anything_transitions=([3]=2)
    declare -A subword_transitions=()

    declare state=1
    declare word_index=2
    while [[ $word_index -lt $CURRENT ]]; do
        if [[ -v "literal_transitions[$state]" ]]; then
            eval "declare -A state_transitions=${literal_transitions[$state]}"

            declare word=${words[$word_index]}
            declare word_matched=0
            for ((literal_id = 1; literal_id <= $#literals; literal_id++)); do
                if [[ ${literals[$literal_id]} = "$word" ]]; then
                    if [[ -v "state_transitions[$literal_id]" ]]; then
                        state=${state_transitions[$literal_id]}
                        word_index=$((word_index + 1))
                        word_matched=1
                        break
                    fi
                fi
            done
            if [[ $word_matched -ne 0 ]]; then
                continue
            fi
        fi

        if [[ -v "nontail_transitions[$state]" ]]; then
            eval "declare -A state_nontails=${nontail_transitions[$state]}"
            declare nontail_matched=0
            for regex_id in "${(k)state_nontails}"; do
                declare regex="^(${regexes[$regex_id]}).*"
                if [[ ${subword} =~ $regex && -n ${match[1]} ]]; then
                    match="${match[1]}"
                    match_len=${#match}
                    char_index=$((char_index + match_len))
                    state=${state_nontails[$regex_id]}
                    nontail_matched=1
                    break
                fi
            done
            if [[ $nontail_matched -ne 0 ]]; then
                continue
            fi
        fi


        if [[ -v "match_anything_transitions[$state]" ]]; then
            state=${match_anything_transitions[$state]}
            word_index=$((word_index + 1))
            continue
        fi

        return 1
    done

    declare -A literal_transitions_level_0=([5]="49 50 51" [1]="1 2 3 4 45 46 47 48" [4]="5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44" [2]="1 2 3 4 45 46 47 48")
    declare -A subword_transitions_level_0=()
    declare -A commands_level_0=()
    declare -A nontail_commands_level_0=()
    declare -A nontail_regexes_level_0=()
    declare -A specialized_commands_level_0=()

    declare max_fallback_level=0
    for (( fallback_level=0; fallback_level <= max_fallback_level; fallback_level++ )); do
        completions_no_description_trailing_space=()
        completions_no_description_no_trailing_space=()
        completions_trailing_space=()
        suffixes_trailing_space=()
        descriptions_trailing_space=()
        completions_no_trailing_space=()
        suffixes_no_trailing_space=()
        descriptions_no_trailing_space=()
        matches=()

        declare literal_transitions_name=literal_transitions_level_${fallback_level}
        eval "declare initializer=\${${literal_transitions_name}[$state]}"
        eval "declare -a transitions=($initializer)"
        for literal_id in "${transitions[@]}"; do
            if [[ -v "descr_id_from_literal_id[$literal_id]" ]]; then
                declare descr_id=$descr_id_from_literal_id[$literal_id]
                completions_trailing_space+=("${literals[$literal_id]}")
                suffixes_trailing_space+=("${literals[$literal_id]}")
                descriptions_trailing_space+=("${descrs[$descr_id]}")
            else
                completions_no_description_trailing_space+=("${literals[$literal_id]}")
            fi
        done

        declare subword_transitions_name=subword_transitions_level_${fallback_level}
        eval "declare initializer=\${${subword_transitions_name}[$state]}"
        eval "declare -a transitions=($initializer)"
        for subword_id in "${transitions[@]}"; do
            _wcli_subword_${subword_id} complete "${words[$CURRENT]}"
            completions_no_description_trailing_space+=("${subword_completions_no_description_trailing_space[@]}")
            completions_trailing_space+=("${subword_completions_trailing_space[@]}")
            completions_no_trailing_space+=("${subword_completions_no_trailing_space[@]}")
            suffixes_no_trailing_space+=("${subword_suffixes_no_trailing_space[@]}")
            suffixes_trailing_space+=("${subword_suffixes_trailing_space[@]}")
            descriptions_trailing_space+=("${subword_descriptions_trailing_space[@]}")
            descriptions_no_trailing_space+=("${subword_descriptions_no_trailing_space[@]}")
        done

        declare commands_name=commands_level_${fallback_level}
        eval "declare initializer=\${${commands_name}[$state]}"
        eval "declare -a transitions=($initializer)"
        for command_id in "${transitions[@]}"; do
            declare output=$(_wcli_cmd_${command_id} "${words[$CURRENT]}")
            declare -a command_completions=("${(@f)output}")
            for line in ${command_completions[@]}; do
                declare parts=(${(@s:	:)line})
                if [[ -v "parts[2]" ]]; then
                    completions_trailing_space+=("${parts[1]}")
                    suffixes_trailing_space+=("${parts[1]}")
                    descriptions_trailing_space+=("${parts[2]}")
                else
                    completions_no_description_trailing_space+=("${parts[1]}")
                fi
            done
        done

        declare commands_name=nontail_commands_level_${fallback_level}
        eval "declare command_initializer=\${${commands_name}[$state]}"
        eval "declare -a command_transitions=($command_initializer)"
        declare regexes_name=nontail_regexes_level_${fallback_level}
        eval "declare regexes_initializer=\${${regexes_name}[$state]}"
        eval "declare -a regexes_transitions=($regexes_initializer)"
        for (( i=1; i <= ${#command_transitions[@]}; i++ )); do
            declare command_id=${command_transitions[$i]}
            declare regex_id=${regexes_transitions[$i]}
            declare regex="^(${regexes[$regex_id]}).*"
            declare output=$(_wcli_cmd_${command_id} "${words[$CURRENT]}")
            declare -a command_completions=("${(@f)output}")
            for line in ${command_completions[@]}; do
                declare parts=(${(@s:	:)line})
                if [[ ${parts[1]} =~ $regex && -n ${match[1]} ]]; then
                    parts[1]=${match[1]}
                    if [[ -v "parts[2]" ]]; then
                        completions_trailing_space+=("${parts[1]}")
                        suffixes_trailing_space+=("${parts[1]}")
                        descriptions_trailing_space+=("${parts[2]}")
                    else
                        completions_no_description_trailing_space+=("${parts[1]}")
                    fi
                fi
            done
        done

        declare specialized_commands_name=specialized_commands_level_${fallback_level}
        eval "declare initializer=\${${specialized_commands_name}[$state]}"
        eval "declare -a transitions=($initializer)"
        for command_id in "${transitions[@]}"; do
            _wcli_cmd_${command_id} ${words[$CURRENT]}
        done

        declare maxlen=0
        for suffix in ${suffixes_trailing_space[@]}; do
            if [[ ${#suffix} -gt $maxlen ]]; then
                maxlen=${#suffix}
            fi
        done
        for suffix in ${suffixes_no_trailing_space[@]}; do
            if [[ ${#suffix} -gt $maxlen ]]; then
                maxlen=${#suffix}
            fi
        done

        for ((i = 1; i <= $#suffixes_trailing_space; i++)); do
            if [[ -z ${descriptions_trailing_space[$i]} ]]; then
                descriptions_trailing_space[$i]="${(r($maxlen)( ))${suffixes_trailing_space[$i]}}"
            else
                descriptions_trailing_space[$i]="${(r($maxlen)( ))${suffixes_trailing_space[$i]}} -- ${descriptions_trailing_space[$i]}"
            fi
        done

        for ((i = 1; i <= $#suffixes_no_trailing_space; i++)); do
            if [[ -z ${descriptions_no_trailing_space[$i]} ]]; then
                descriptions_no_trailing_space[$i]="${(r($maxlen)( ))${suffixes_no_trailing_space[$i]}}"
            else
                descriptions_no_trailing_space[$i]="${(r($maxlen)( ))${suffixes_no_trailing_space[$i]}} -- ${descriptions_no_trailing_space[$i]}"
            fi
        done

        compadd -O m -a completions_no_description_trailing_space; matches+=("${m[@]}")
        compadd -O m -a completions_no_description_no_trailing_space; matches+=("${m[@]}")
        compadd -O m -a completions_trailing_space; matches+=("${m[@]}")
        compadd -O m -a completions_no_trailing_space; matches+=("${m[@]}")

        if [[ ${#matches} -gt 0 ]]; then
            compadd -Q -a completions_no_description_trailing_space
            compadd -Q -S ' ' -a completions_no_description_no_trailing_space
            compadd -l -Q -a -d descriptions_trailing_space completions_trailing_space
            compadd -l -Q -S '' -a -d descriptions_no_trailing_space completions_no_trailing_space
            return 0
        fi
    done
}

if [[ $ZSH_EVAL_CONTEXT =~ :file$ ]]; then
    compdef _wcli wcli
else
    _wcli
fi
