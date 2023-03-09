# aws-cli-mfa
Python + shell script to streamline official AWS process for using MFA with the AWS CLI

Matches to: https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/

## Usage

#### Source
Note that you MUST [`source`](https://linuxize.com/post/bash-source-command/) (or its synonym `.`) to change env vars in your current shell:

    . aws-cli-mfa $AWS_MFA_ARN 123456
    . aws-cli-mfa $AWS_MFA_ARN 123456 -p rogusdev -d 57600

Meaning, *the period at the beginning of those lines above is a critical, vital part of using this application*.

If using Fish, you will need to use a slight workaround due to how Fish's [source](https://fishshell.com/docs/current/cmds/source.html) command only resolves relative paths from the current directory:

    . (which aws-cli-mfa) $AWS_MFA_ARN 123456

An easy way to test that everything is working is simply:

    aws s3 ls

Note that aws cli commands will only work in the terminal you `source`-d this script in. If you want to use `aws` in other terminals, you will need to pass `--profile mfa` at the end ala `aws s3 ls --profile mfa` or you can `export AWS_PROFILE=mfa` in the appropriate profile/rc file to make that your default aws profile (for everything!).

#### Dependencies
You must have `jq`, python 3 (as `python3`), and the aws cli (as `aws`) available on your PATH in your shell.

#### Arguments
You will pass, at a minimum, your AWS MFA ARN and the current MFA auth token from your 2fa/mfa authenticator app/device. This does not work with yubikeys/etc (per [AWS docs](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/)). There are additional optional args to change the effects this script has on your system.

#### MFA ARN
I recommend you have your AWS_MFA_ARN in your `.bash_profile`, `.zshrc`, or [config.fish](https://fishshell.com/docs/current/language.html#configuration) or as appropriate for your shell:

    echo 'export AWS_MFA_ARN=arn:aws:iam::NUMBER:mfa/USERNAME' >> $HOME/.bash_profile

Or if using Fish:

    echo 'set -x AWS_MFA_ARN arn:aws:iam::NUMBER:mfa/USERNAME' >> $HOME/.config/fish/config.fish

Replacing the number and username as appropriate. Your MFA ARN is on this page:\
https://console.aws.amazon.com/iam/home?#/security_credentials

#### Help
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

Installing `python3` can be done in a variety of ways, however I recommend using `asdf`: https://github.com/danhper/asdf-python

## Building from src
Clone the repo and create all shells' final `aws-cli-mfa-*` scripts and then copy your preference like so:

    ./build.sh && sudo cp ./bin/aws-cli-mfa-SHELL /usr/local/bin/aws-cli-mfa

Where SHELL is one of the available shell options: `bash`, `zsh`, `ksh`, `fish`

(For the curious, the `-e "s///"` gets rid of the `#INSERT_PYTHON_CODE_HERE`.)

## Testing
Tests for the core python functionality to call the aws cli with the right args and parse the results:

    python3 -m unittest tests.aws_cli_mfa_tests

Tests for the shell scripts that wrap around the python script to set env vars when sourced:

    ./tests/tests.sh && ./tests/tests.fish