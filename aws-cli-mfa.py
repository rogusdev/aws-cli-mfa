#!/usr/bin/env python3

# Follow the directions from AWS on using MFA with CLI:
#  https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/

# That means: call STS with an ARN and an MFA token,
#  with the response, populate an MFA section in aws creds file
#  and, by default, use that profile after you run this

# TODO: option to name profile something other than mfa
# TODO: option to not use the mfa profile after running
# TODO: option to update env vars only, not write profile at all

# TODO: write the code here
import configparser
import argparse

config = configparser.ConfigParser()
argparser = argparse.ArgumentParser(description='Process some integers.')


argparser.add_argument('--profile-arn',
    help='the AWS ARN for your MFA profile')
argparser.add_argument('--mfa-token',
    help='the MFA token from your authenticator app for the MFA profile your ARN is for')
argparser.add_argument('--aws-creds-mfa-profile', default='mfa',
    help='profile to save MFA credentials to in AWS credentials file (default: mfa)')
argparser.add_argument('--aws-creds-file', default='~/.aws/credentials',
    help='file path to AWS credentials file (default: ~/.aws/credentials)')

args = parser.parse_args()
config.read('~/.aws/credentials')
