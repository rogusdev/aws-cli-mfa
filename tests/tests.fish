#!/usr/bin/env fish

set BASE_DIR (dirname (status -f))

function test_program
    set TEST_SHELL $argv[1]
    set TEST_SCRIPT $argv[2]
    set TEST_MODE $argv[3]
    set TEST_ARG $argv[4]
    set TEST_EXPECTED $argv[5]

    set tmpfile (mktemp)
    echo "$TEST_SCRIPT" > "$tmpfile"

    # Fish shell's 'status current-command' built-in returns 'fish' instead of 'source' when sourcing 
    # from a command substitution, so setting an environment variable is a hacky workaround to get
    # the tests to pass
    if test "$TEST_MODE" = "source"
        set -x IS_SOURCED true
        set TEST_OUT ($TEST_SHELL -c "source $tmpfile $TEST_ARG" | string collect)
        set -e IS_SOURCED
    else if test "$TEST_MODE" = "direct"
        chmod +x "$tmpfile"
        set TEST_OUT ($TEST_SHELL -c "$tmpfile $TEST_ARG" | string collect)
    else if test "$TEST_MODE" = "envgrep"
        set -x IS_SOURCED true
        set TEST_OUT ($TEST_SHELL -c "source $tmpfile $TEST_ARG; env | sort | grep TEST_AWS_CLI_MFA" | string collect)
        set -e IS_SOURCED
    else
        echo "BAD TEST ARG!"
        return
    end

    rm "$tmpfile"

    if test "$TEST_OUT" = "$TEST_EXPECTED"
        echo "SUCCESS - $TEST_SHELL $TEST_MODE: $TEST_ARG"
    else
        echo "$TEST_EXPECTED"
        echo "FAILURE - $TEST_SHELL $TEST_MODE: $TEST_ARG: $TEST_OUT"
    end
end

set FISH_SCRIPT (string replace --all '"' '\\"' < $BASE_DIR/test_sh.py | sed -e "/#INSERT_PYTHON_CODE_HERE/r /dev/stdin" -e "s///" $BASE_DIR/../src/mfa.fish | string collect)

test_program fish (string replace "python3" "python1" $FISH_SCRIPT | string collect) source python3 "python1 could not be found!"
test_program fish (string replace "python3" "python1" $FISH_SCRIPT | string collect) direct python3 "python1 could not be found!"
test_program fish (string replace "aws" "aws1" $FISH_SCRIPT | string collect) source aws "aws1 could not be found!"
test_program fish (string replace "aws" "aws1" $FISH_SCRIPT | string collect) direct aws "aws1 could not be found!"
test_program fish (string replace "jq" "jq1" $FISH_SCRIPT | string collect) source jq "jq1 could not be found!"
test_program fish (string replace "jq" "jq1" $FISH_SCRIPT | string collect) direct jq "jq1 could not be found!"
test_program fish $FISH_SCRIPT source usage "usage instructions"
test_program fish $FISH_SCRIPT direct usage "usage instructions"
test_program fish $FISH_SCRIPT source notjson "JSON parsing failed:
not json"
test_program fish $FISH_SCRIPT direct notjson "JSON parsing failed:
not json"
test_program fish $FISH_SCRIPT source sts "aws sts something something"
test_program fish $FISH_SCRIPT direct sts "aws sts something something"
test_program fish $FISH_SCRIPT source output "aws sts something something
output across
multiple lines"
test_program fish $FISH_SCRIPT direct output "aws sts something something
output across
multiple lines"
test_program fish $FISH_SCRIPT source envvars "sts
output
Set env var: TEST_AWS_CLI_MFA_1
Set env var: TEST_AWS_CLI_MFA_2"
test_program fish $FISH_SCRIPT direct envvars "sts
output
You must source this file to get the exports in your shell"
test_program fish $FISH_SCRIPT envgrep envvars "sts
output
Set env var: TEST_AWS_CLI_MFA_1
Set env var: TEST_AWS_CLI_MFA_2
TEST_AWS_CLI_MFA_1=val1
TEST_AWS_CLI_MFA_2=val2"

