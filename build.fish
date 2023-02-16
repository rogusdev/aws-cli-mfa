#!/usr/bin/env fish

set AWS_CLI_MFA_SHELL fish; and \
string replace --all '"' '\\"' < ./src/aws_cli_mfa.py | sed -e "/#INSERT_PYTHON_CODE_HERE/r /dev/stdin" -e "s///" ./src/mfa.fish |
    sudo tee /usr/local/bin/aws-cli-mfa >/dev/null &&
    sudo chmod +x /usr/local/bin/aws-cli-mfa &&
    cp /usr/local/bin/aws-cli-mfa ./bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL
