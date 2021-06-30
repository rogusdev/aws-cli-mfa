# aws-cli-mfa
Python + shell script to streamline official AWS process for using MFA with the AWS CLI

Matches to: https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/

## Usage
Note that you MUST `source` (or its synonym `.`) to change env vars in your current shell:

    . aws-cli-mfa $AWS_MFA_ARN 123456
    . aws-cli-mfa $AWS_MFA_ARN 123456 -p rogusdev -d 57600

You must have `jq`, python 3 (as `python3`), and the aws cli (as `aws`) available on your PATH in your shell.

You will pass, at a minimum, your AWS MFA ARN and the current MFA auth token from your 2fa/mfa authenticator app/device. This does not work with yubikeys/etc (per AWS docs). There are additional optional args to change the effects this script has on your system.

I recommend you have your AWS_MFA_ARN in your `.bash_profile` or as appropriate for your shell:

    echo 'export AWS_MFA_ARN=arn:aws:iam::NUMBER:mfa/USERNAME' >> $HOME/.bash_profile

Replacing the number and username as appropriate. Your MFA ARN is on this page:\
https://console.aws.amazon.com/iam/home?#/security_credentials

To see all the options, run the script with `-h`:

    aws-cli-mfa -h

## Installation
Use the correct shell for where you are going to use this:

    AWS_CLI_MFA_SHELL=bash &&
    wget https://raw.githubusercontent.com/rogusdev/aws-cli-mfa/main/bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL -O aws-cli-mfa &&
      sudo mv aws-cli-mfa /usr/local/bin/ && sudo chmod +x /usr/local/bin/aws-cli-mfa

You might also need to install dependencies as well:

Installing `jq` and `wget` (in case you don't have wget to download this script as above):

    brew install jq wget # osx
    sudo apt-get install jq wget # debian/ubuntu
    # etc

Installing `aws`: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

Installing `python3` can be done in a variet of ways, however I recommend using `asdf`: https://github.com/danhper/asdf-python

## Building from src
Clone the repo and create all shells' final `aws-cli-mfa-*` scripts and then copy your preference like so:

    AWS_CLI_MFA_SHELL=bash &&
    ./build.sh && sudo cp ./bin/aws-cli-mfa-$AWS_CLI_MFA_SHELL /usr/local/bin/aws-cli-mfa

Current shell options are: `bash`, `zsh`, `ksh`

(For the curious, the `-e "s///"` gets rid of the `#INSERT_PYTHON_CODE_HERE`.)

## Testing
Tests for the core python functionality to call the aws cli with the right args and parse the results:

    python3 -m unittest tests.aws_cli_mfa_tests

Tests for the shell scripts that wrap around the python script to set env vars when sourced:

    ./tests/tests.sh
