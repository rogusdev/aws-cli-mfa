# aws-cli-mfa
Python+bash script to streamline official AWS process for using MFA with the AWS CLI

Matches to: https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/

## Usage
    . aws-cli-mfa $AWS_MFA_ARN 123456
    . aws-cli-mfa $AWS_MFA_ARN 123456 -p rogusdev -d 57600 -e -x

I recommend you have your AWS_MFA_ARN in your `.bash_profile` or as appropriate for your shell:

    echo 'export AWS_MFA_ARN=arn:aws:iam::NUMBER:mfa/USERNAME' >> $HOME/.bash_profile

Replacing the number and username as appropriate. Your MFA ARN is on this page:\
https://console.aws.amazon.com/iam/home?#/security_credentials

## Installation

    sed -e "/INSERT_PYTHON_CODE_HERE/r ./src/aws_cli_mfa.py" -e "s///" ./aws-cli-mfa.bash | sudo tee /usr/local/bin/aws-cli-mfa > /dev/null && chmod +x /usr/local/bin/aws-cli-mfa

## Testing

    python3 -m unittest tests.aws_cli_mfa_tests

## Alternatives
There are other options that take slightly different views on how to do this:\
https://github.com/broamski/aws-mfa \
https://github.com/dcoker/awsmfa

They are not quite aligned with the official AWS recommendations, at least not by default.
