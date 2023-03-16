#!/usr/bin/env bash

AWS_CLI_MFA_SHELL=bash && \
sed -e "/#INSERT_PYTHON_CODE_HERE/r ./src/aws_cli_mfa.py" -e "s///" ./src/$AWS_CLI_MFA_SHELL.sh > ./bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL &&
chmod +x ./bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL

AWS_CLI_MFA_SHELL=zsh && \
sed -e "/#INSERT_PYTHON_CODE_HERE/r ./src/aws_cli_mfa.py" -e "s///" ./src/$AWS_CLI_MFA_SHELL.sh > ./bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL &&
chmod +x ./bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL

AWS_CLI_MFA_SHELL=ksh && \
sed -e "/#INSERT_PYTHON_CODE_HERE/r ./src/aws_cli_mfa.py" -e "s///" ./src/$AWS_CLI_MFA_SHELL.sh > ./bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL &&
chmod +x ./bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL

AWS_CLI_MFA_SHELL=fish && \
sed 's/"/\\\"/g' ./src/aws_cli_mfa.py | sed -e "/#INSERT_PYTHON_CODE_HERE/r /dev/stdin" -e "s///" ./src/mfa.fish > ./bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL &&
chmod +x ./bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL
