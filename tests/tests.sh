#!/bin/bash

BASE_DIR=$(dirname "${BASH_SOURCE[0]}")

function test {
    TEST_SHELL=$1
    TEST_MODE=$2
    TEST_SCRIPT=$3
    TEST_ARG=$4
    TEST_EXPECTED=$5

    # https://github.com/fish-shell/fish-shell/issues/2314#issuecomment-698645423
    #TEST_OUT=$($TEST_SHELL -c "$TEST_SCRIPT" ignored_argv0 $TEST_ARG)

    tmpfile=$(mktemp)
    echo "$TEST_SCRIPT" >"$tmpfile"

    case $TEST_MODE in
        "source")
            TEST_OUT=$($TEST_SHELL -c "source $tmpfile $TEST_ARG")
            ;;

        "direct")
            chmod +x "$tmpfile"
            TEST_OUT=$($TEST_SHELL -c "$tmpfile $TEST_ARG")
            ;;

        "envgrep")
            TEST_OUT=$($TEST_SHELL -c "source $tmpfile $TEST_ARG && env | grep TEST_AWS_CLI_MFA")
            ;;

        *)
            echo "BAD TEST ARG!"
            return
            ;;
    esac

    rm "$tmpfile"

    if [ "$TEST_OUT" = "$TEST_EXPECTED" ]; then
        echo "SUCCESS - $TEST_SHELL $TEST_MODE: $TEST_ARG"
    else
        echo "$TEST_EXPECTED"
        echo "FAILURE - $TEST_SHELL $TEST_MODE: $TEST_ARG: $TEST_OUT"
    fi
}


BASH_SCRIPT=$(sed -e "/#INSERT_PYTHON_CODE_HERE/r $BASE_DIR/test_sh.py" -e "s///" $BASE_DIR/../src/bash.sh)

test bash source "$BASH_SCRIPT" usage "usage instructions"
test bash direct "$BASH_SCRIPT" usage "usage instructions"
test bash source "$BASH_SCRIPT" notjson "JSON parsing failed:
not json"
test bash direct "$BASH_SCRIPT" notjson "JSON parsing failed:
not json"
test bash source "$BASH_SCRIPT" sts "aws sts something something"
test bash direct "$BASH_SCRIPT" sts "aws sts something something"
test bash source "$BASH_SCRIPT" output "aws sts something something
output across
multiple lines"
test bash direct "$BASH_SCRIPT" output "aws sts something something
output across
multiple lines"
test bash source "$BASH_SCRIPT" envvars "sts
output
Set env var: TEST_AWS_CLI_MFA_1
Set env var: TEST_AWS_CLI_MFA_2"
test bash direct "$BASH_SCRIPT" envvars "sts
output
You must source this file to get the exports in your shell"
test bash envgrep "$BASH_SCRIPT" envvars "sts
output
Set env var: TEST_AWS_CLI_MFA_1
Set env var: TEST_AWS_CLI_MFA_2
TEST_AWS_CLI_MFA_2=val2
TEST_AWS_CLI_MFA_1=val1"

# TODO: all of the above, but with zsh

# TODO, someday: all of the above, but with fish
