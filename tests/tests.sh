#!/bin/bash

BASE_DIR=$(dirname "${BASH_SOURCE[0]}")

# helpful test debugging lines:
#  PYCODE=$(cat tests/test_sh.py) && COLUMNS=999 /usr/bin/env python3 -c "$PYCODE" output
#  PYCODE=$(cat tests/test_sh.py) && RESPONSE=$(COLUMNS=999 /usr/bin/env python3 -c "$PYCODE" output) && echo "$RESPONSE"
#  BASE_DIR=./tests && sed -e "/#INSERT_PYTHON_CODE_HERE/r $BASE_DIR/test_sh.py" -e "s///" $BASE_DIR/../src/zsh.sh > aws-cli-mfa-test && chmod +x aws-cli-mfa-test


function test {
    TEST_SHELL=$1
    TEST_SCRIPT=$2
    TEST_MODE=$3
    TEST_ARG=$4
    TEST_EXPECTED=$5

    # https://github.com/fish-shell/fish-shell/issues/2314#issuecomment-698645423
    #TEST_OUT=$($TEST_SHELL -c "$TEST_SCRIPT" ignored_argv0 $TEST_ARG)

    tmpfile=$(mktemp)
    echo "$TEST_SCRIPT" >"$tmpfile"

    if [ "$TEST_MODE" = "source" ]; then
        TEST_OUT=$($TEST_SHELL -c "source $tmpfile $TEST_ARG")
    elif [ "$TEST_MODE" = "direct" ]; then
        chmod +x "$tmpfile"
        TEST_OUT=$($TEST_SHELL -c "$tmpfile $TEST_ARG")
    elif [ "$TEST_MODE" = "envgrep" ]; then
        TEST_OUT=$($TEST_SHELL -c "source $tmpfile $TEST_ARG && env | grep TEST_AWS_CLI_MFA")
    else
        echo "BAD TEST ARG!"
        return
    fi

    rm "$tmpfile"

    if [ "$TEST_OUT" = "$TEST_EXPECTED" ]; then
        echo "SUCCESS - $TEST_SHELL $TEST_MODE: $TEST_ARG"
    else
        echo "$TEST_EXPECTED"
        echo "FAILURE - $TEST_SHELL $TEST_MODE: $TEST_ARG: $TEST_OUT"
    fi
}


BASH_SCRIPT=$(sed -e "/#INSERT_PYTHON_CODE_HERE/r $BASE_DIR/test_sh.py" -e "s///" $BASE_DIR/../src/bash.sh)

test bash "${BASH_SCRIPT/python3 /python1 }" source python3 "python3 could not be found!"
test bash "${BASH_SCRIPT/python3 /python1 }" direct python3 "python3 could not be found!"
test bash "${BASH_SCRIPT/aws /aws1 }" source aws "aws could not be found!"
test bash "${BASH_SCRIPT/aws /aws1 }" direct aws "aws could not be found!"
test bash "${BASH_SCRIPT/jq /jq1 }" source jq "jq could not be found!"
test bash "${BASH_SCRIPT/jq /jq1 }" direct jq "jq could not be found!"
test bash "$BASH_SCRIPT" source usage "usage instructions"
test bash "$BASH_SCRIPT" direct usage "usage instructions"
test bash "$BASH_SCRIPT" source notjson "JSON parsing failed:
not json"
test bash "$BASH_SCRIPT" direct notjson "JSON parsing failed:
not json"
test bash "$BASH_SCRIPT" source sts "aws sts something something"
test bash "$BASH_SCRIPT" direct sts "aws sts something something"
test bash "$BASH_SCRIPT" source output "aws sts something something
output across
multiple lines"
test bash "$BASH_SCRIPT" direct output "aws sts something something
output across
multiple lines"
test bash "$BASH_SCRIPT" source envvars "sts
output
Set env var: TEST_AWS_CLI_MFA_1
Set env var: TEST_AWS_CLI_MFA_2"
test bash "$BASH_SCRIPT" direct envvars "sts
output
You must source this file to get the exports in your shell"
test bash "$BASH_SCRIPT" envgrep envvars "sts
output
Set env var: TEST_AWS_CLI_MFA_1
Set env var: TEST_AWS_CLI_MFA_2
TEST_AWS_CLI_MFA_2=val2
TEST_AWS_CLI_MFA_1=val1"


ZSH_SCRIPT=$(sed -e "/#INSERT_PYTHON_CODE_HERE/r $BASE_DIR/test_sh.py" -e "s///" $BASE_DIR/../src/zsh.sh)

test zsh "${ZSH_SCRIPT/python3 /python1 }" source python3 "python3 could not be found!"
test zsh "${ZSH_SCRIPT/python3 /python1 }" direct python3 "python3 could not be found!"
test zsh "${ZSH_SCRIPT/aws /aws1 }" source aws "aws could not be found!"
test zsh "${ZSH_SCRIPT/aws /aws1 }" direct aws "aws could not be found!"
test zsh "${ZSH_SCRIPT/jq /jq1 }" source jq "jq could not be found!"
test zsh "${ZSH_SCRIPT/jq /jq1 }" direct jq "jq could not be found!"
test zsh "$ZSH_SCRIPT" source usage "usage instructions"
test zsh "$ZSH_SCRIPT" direct usage "usage instructions"
test zsh "$ZSH_SCRIPT" source notjson "JSON parsing failed:
not json"
test zsh "$ZSH_SCRIPT" direct notjson "JSON parsing failed:
not json"
test zsh "$ZSH_SCRIPT" source sts "aws sts something something"
test zsh "$ZSH_SCRIPT" direct sts "aws sts something something"
test zsh "$ZSH_SCRIPT" source output "aws sts something something
output across
multiple lines"
test zsh "$ZSH_SCRIPT" direct output "aws sts something something
output across
multiple lines"
test zsh "$ZSH_SCRIPT" source envvars "sts
output
Set env var: TEST_AWS_CLI_MFA_1
Set env var: TEST_AWS_CLI_MFA_2"
test zsh "$ZSH_SCRIPT" direct envvars "sts
output
You must source this file to get the exports in your shell"
test zsh "$ZSH_SCRIPT" envgrep envvars "sts
output
Set env var: TEST_AWS_CLI_MFA_1
Set env var: TEST_AWS_CLI_MFA_2
TEST_AWS_CLI_MFA_1=val1
TEST_AWS_CLI_MFA_2=val2"


KSH_SCRIPT=$(sed -e "/#INSERT_PYTHON_CODE_HERE/r $BASE_DIR/test_sh.py" -e "s///" $BASE_DIR/../src/ksh.sh)

test ksh "${KSH_SCRIPT/python3 /python1 }" source python3 "python3 could not be found!"
test ksh "${KSH_SCRIPT/python3 /python1 }" direct python3 "python3 could not be found!"
test ksh "${KSH_SCRIPT/aws /aws1 }" source aws "aws could not be found!"
test ksh "${KSH_SCRIPT/aws /aws1 }" direct aws "aws could not be found!"
test ksh "${KSH_SCRIPT/jq /jq1 }" source jq "jq could not be found!"
test ksh "${KSH_SCRIPT/jq /jq1 }" direct jq "jq could not be found!"
test ksh "$KSH_SCRIPT" source usage "usage instructions"
test ksh "$KSH_SCRIPT" direct usage "usage instructions"
test ksh "$KSH_SCRIPT" source notjson "JSON parsing failed:
not json"
test ksh "$KSH_SCRIPT" direct notjson "JSON parsing failed:
not json"
test ksh "$KSH_SCRIPT" source sts "aws sts something something"
test ksh "$KSH_SCRIPT" direct sts "aws sts something something"
test ksh "$KSH_SCRIPT" source output "aws sts something something
output across
multiple lines"
test ksh "$KSH_SCRIPT" direct output "aws sts something something
output across
multiple lines"
test ksh "$KSH_SCRIPT" source envvars "sts
output
Set env var: TEST_AWS_CLI_MFA_1
Set env var: TEST_AWS_CLI_MFA_2"
test ksh "$KSH_SCRIPT" direct envvars "sts
output
You must source this file to get the exports in your shell"
test ksh "$KSH_SCRIPT" envgrep envvars "sts
output
Set env var: TEST_AWS_CLI_MFA_1
Set env var: TEST_AWS_CLI_MFA_2
TEST_AWS_CLI_MFA_1=val1
TEST_AWS_CLI_MFA_2=val2"


# TODO, someday: all of the above, but with csh, tcsh, fish
