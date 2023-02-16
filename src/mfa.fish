#!/usr/bin/env fish

# you MUST source this file to get the exports in your shell!
set IS_SOURCED_COMMANDS . source

if contains (status current-command) $IS_SOURCED_COMMANDS; or test -n "$IS_SOURCED"
    set SOURCED 1
else
    set SOURCED 0
end

set -l REQUIREMENTS python3 aws jq

for requirement in $REQUIREMENTS
    if not command -v $requirement &> /dev/null
        echo "$requirement could not be found!"
        exit 0
    end
end

set -l PYCODE "
#INSERT_PYTHON_CODE_HERE
"

set -l RESPONSE (/usr/bin/env python3 -c "$PYCODE" $argv)

if string match -r "^usage" "$RESPONSE" &> /dev/null
    echo "$RESPONSE"
    exit 0
end

if not echo "$RESPONSE" | jq -e . &> /dev/null
    echo "JSON parsing failed:"
    echo "$RESPONSE"
    exit 1
end

set -l STS_CMD (echo "$RESPONSE" | jq -r ".sts_cmd") 
set -l OUTPUT (echo "$RESPONSE" | jq -r ".output" | string collect)

if not test null = "$STS_CMD"
    echo "$STS_CMD"
end

if not test null = "$OUTPUT"
    echo "$OUTPUT"
end

set -l ENVVARS (echo "$RESPONSE" | jq -r ".envvars")

if test null = "$ENVVARS"
    exit 0
end

set -l KEYS (echo "$RESPONSE" | jq -r ".envvars | keys[]")
if test (count $KEYS) -ge 0 -a $SOURCED -ne 1
    echo "You must source this file to get the exports in your shell"
    exit 1
end

for key in $KEYS
    set value (echo "$RESPONSE" | jq -r ".envvars.$key")
    set -x $key $value
    echo "Set env var: $key"
end

