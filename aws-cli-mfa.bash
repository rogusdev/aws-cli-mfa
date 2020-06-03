# you MUST source this file to get the exports in your shell!


PYCODE=$(cat << EOF
INSERT_PYTHON_CODE_HERE
EOF
)

RESPONSE=$(COLUMNS=999 /usr/bin/env python3 -c "$PYCODE" $@)

if [[ $RESPONSE == usage* ]] ; then
    echo "$RESPONSE"
    return 2>/dev/null || exit
fi

STS_CMD=$(echo $RESPONSE | jq -r .sts_cmd)
OUTPUT=$(echo $RESPONSE | jq -r .output)

[[ ! -z "$STS_CMD" ]] && echo $STS_CMD
[[ ! -z "$OUTPUT" && "null" != "$OUTPUT" ]] && echo $OUTPUT


[[ null == "$(echo $RESPONSE | jq -r '.envvars')" ]] && return 2>/dev/null || exit

KEYS=( $(echo $RESPONSE | jq -r '.envvars | keys[]') )

[[ ${#KEYS[@]} -ge 0 ]] && [[ "${BASH_SOURCE[0]}" == "${0}" ]] && echo "You must source this file to get the exports in your shell" && return 2>/dev/null || exit

for key in "${KEYS[@]}" ; do
    value=$(echo $RESPONSE | jq -r ".envvars.$key")
    export $key=$value
    echo "Set env var: $key"
done
