# aws-cli-mfa
Python script to streamline official AWS process for using MFA with AWS CLI

Match to: https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/

## Usage
    aws-cli-mfa $AWS_MFA_ARN 123456
    aws-cli-mfa $AWS_MFA_ARN 123456 -p rogusdev -d 129600 -e -x

I recommend you have your AWS_MFA_ARN in your `.bashrc` or as appropriate:

    echo 'export AWS_MFA_ARN=arn:aws:iam::NUMBER:mfa/USERNAME' >> $HOME/.bash_profile

Replacing the number and username as appropriate. Your MFA ARN is on this page:
https://console.aws.amazon.com/iam/home?#/security_credentials

## Alternatives
There are other options that take slightly different views on how to do this:\
https://github.com/broamski/aws-mfa \
https://github.com/dcoker/awsmfa

They are not quite aligned with the official AWS recommendations, at least not by default.
