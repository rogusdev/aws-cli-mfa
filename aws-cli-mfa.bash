# you MUST source this file to get the exports in your shell!

#RESPONSE=$(./aws-cli-mfa.py $@)

PYCODE=$(cat << EOF
INSERT_PYTHON_CODE_HERE
EOF
)

RESPONSE=$(/usr/bin/env python3 -c "$PYCODE" $@)

#echo $RESPONSE


STS_CMD=$(echo $RESPONSE | jq -r .sts_cmd)
OUTPUT=$(echo $RESPONSE | jq -r .output)

[[ ! -z "$STS_CMD" ]] && echo $STS_CMD
[[ ! -z "$OUTPUT" ]] && echo $OUTPUT


# https://stackoverflow.com/questions/34529156/iterate-through-dictionaries-jq-shell
# https://www.cyberciti.biz/faq/bash-for-loop-array/
KEYS=( $(echo $RESPONSE | jq -r '.envvars | keys[]') )

for key in "${KEYS[@]}" ; do
    value=$(echo $RESPONSE | jq -r ".envvars.$key")
    export $key=$value
    echo "Set env var: $key"
done
