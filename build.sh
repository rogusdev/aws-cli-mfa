#!/usr/bin/env bash

AWS_CLI_MFA_SHELL=bash && \
sed -e "/#INSERT_PYTHON_CODE_HERE/r ./src/aws_cli_mfa.py" -e "s///" ./src/$AWS_CLI_MFA_SHELL.sh |
    sudo tee /usr/local/bin/aws-cli-mfa >/dev/null &&
    sudo chmod +x /usr/local/bin/aws-cli-mfa &&
    cp /usr/local/bin/aws-cli-mfa ./bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL

AWS_CLI_MFA_SHELL=zsh && \
sed -e "/#INSERT_PYTHON_CODE_HERE/r ./src/aws_cli_mfa.py" -e "s///" ./src/$AWS_CLI_MFA_SHELL.sh |
    sudo tee /usr/local/bin/aws-cli-mfa >/dev/null &&
    sudo chmod +x /usr/local/bin/aws-cli-mfa &&
    cp /usr/local/bin/aws-cli-mfa ./bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL

AWS_CLI_MFA_SHELL=ksh && \
sed -e "/#INSERT_PYTHON_CODE_HERE/r ./src/aws_cli_mfa.py" -e "s///" ./src/$AWS_CLI_MFA_SHELL.sh |
    sudo tee /usr/local/bin/aws-cli-mfa >/dev/null &&
    sudo chmod +x /usr/local/bin/aws-cli-mfa &&
    cp /usr/local/bin/aws-cli-mfa ./bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL

sudo rm -f /usr/local/bin/aws-cli-mfa
