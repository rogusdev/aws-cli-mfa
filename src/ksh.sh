#!/usr/bin/env ksh

# you MUST source this file to get the exports in your shell!


# https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced/28776166#28776166
([[ -n $ZSH_EVAL_CONTEXT && $ZSH_EVAL_CONTEXT =~ :file$ ]] ||
 [[ -n $KSH_VERSION && $(cd "$(dirname -- "$0")" &&
    printf '%s' "${PWD%/}/")$(basename -- "$0") != "${.sh.file}" ]] ||
 [[ -n $BASH_VERSION ]] && (return 0 2>/dev/null)) &&
    SOURCED=1 || SOURCED=0


# https://stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script
if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 could not be found!"
    [[ $SOURCED -eq 1 ]] && return 0 || exit 0
fi

if ! command -v aws >/dev/null 2>&1; then
    echo "aws could not be found!"
    [[ $SOURCED -eq 1 ]] && return 0 || exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "jq could not be found!"
    [[ $SOURCED -eq 1 ]] && return 0 || exit 0
fi


PYCODE=$(cat << EOF
#INSERT_PYTHON_CODE_HERE
EOF
)

RESPONSE=$(COLUMNS=999 /usr/bin/env python3 -c "$PYCODE" $@)


if [[ "$RESPONSE" == usage* ]] ; then
    echo "$RESPONSE"
    [[ $SOURCED -eq 1 ]] && return 0 || exit 0
fi

if ! echo "$RESPONSE" | jq -e . >/dev/null 2>&1; then
    echo "JSON parsing failed:"
    echo "$RESPONSE"
    [[ $SOURCED -eq 1 ]] && return 1 || exit 1
fi

STS_CMD=$(echo "$RESPONSE" | jq -r .sts_cmd)
OUTPUT=$(echo "$RESPONSE" | jq -r .output)

[[ ! -z "$STS_CMD" ]] && echo "$STS_CMD"
[[ ! -z "$OUTPUT" && "null" != "$OUTPUT" ]] && echo "$OUTPUT"


# https://unix.stackexchange.com/questions/88850/precedence-of-the-shell-logical-operators
[[ "null" == "$(echo "$RESPONSE" | jq -r '.envvars')" ]] &&
    { [[ $SOURCED -eq 1 ]] && return 0 || exit 0; }

KEYS=( $(echo "$RESPONSE" | jq -r '.envvars | keys[]') )

[[ ${#KEYS[@]} -ge 0 ]] && [[ $SOURCED -ne 1 ]] &&
    echo "You must source this file to get the exports in your shell" &&
    exit 1

for key in "${KEYS[@]}" ; do
    value=$(echo "$RESPONSE" | jq -r ".envvars.$key")
    export $key=$value
    echo "Set env var: $key"
done
