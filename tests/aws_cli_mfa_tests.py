import unittest
from unittest.mock import Mock, patch

import json

from src.aws_cli_mfa import (
    # not going to test this as it is generic python
    #  -- maybe could test names/etc of args? but nah
#    parse_cli_args,
    gen_sts_cmd,
    # not going to test this as it is similarly generic python
    #  -- could maybe test that it uses the correct section and contents...
#    write_config,
    apply_sts_json,
    build_response
)


class TestAwsCliMfa(unittest.TestCase):

    @staticmethod
    def _mock_cli_args(
        profile_arn = None,
        mfa_token = None,
        aws_profile = None,
        lifetime_duration = None
    ):
        cli_args = Mock()
        cli_args.profile_arn = profile_arn
        cli_args.mfa_token = mfa_token
        cli_args.aws_profile = aws_profile
        cli_args.lifetime_duration = lifetime_duration
        return cli_args

    @staticmethod
    def _sts_json():
        return {
            "Credentials": {
                "AccessKeyId": "xxx",
                "SecretAccessKey": "yyy",
                "SessionToken": "zzz",
            }
        }

    def test_gen_sts_cmd_min(self):
        cli_args = self._mock_cli_args(
            profile_arn = 'ARN',
            mfa_token = 'MFA',
            aws_profile = None,
            lifetime_duration = None
        )
        self.assertEqual(
            "aws sts get-session-token --serial-number ARN --token-code MFA",
            gen_sts_cmd(cli_args))

    def test_gen_sts_cmd_profile(self):
        cli_args = self._mock_cli_args(
            profile_arn = 'ARN',
            mfa_token = 'MFA',
            aws_profile = 'pro',
            lifetime_duration = None
        )
        self.assertEqual(
            "aws sts get-session-token --profile pro --serial-number ARN --token-code MFA",
            gen_sts_cmd(cli_args))

    def test_gen_sts_cmd_duration(self):
        cli_args = self._mock_cli_args(
            profile_arn = 'ARN',
            mfa_token = 'MFA',
            aws_profile = None,
            lifetime_duration = '1234'
        )
        self.assertEqual(
            "aws sts get-session-token --serial-number ARN --token-code MFA --duration-seconds 1234",
            gen_sts_cmd(cli_args))

    def test_gen_sts_cmd_profile_duration(self):
        cli_args = self._mock_cli_args(
            profile_arn = 'ARN',
            mfa_token = 'MFA',
            aws_profile = 'pro',
            lifetime_duration = '1234'
        )
        self.assertEqual(
            "aws sts get-session-token --profile pro --serial-number ARN --token-code MFA --duration-seconds 1234",
            gen_sts_cmd(cli_args))


    def test_apply_sts_json_env_profile(self):
        envvars = apply_sts_json(
            self._sts_json(),
            True,
            "/path/to/creds",
            "mfa",
            True
        )
        self.assertEqual(
            {
                # NOTE: even with profile export true,
                #  if no profile was written (instead wrote env vars),
                #  there's no AWS_PROFILE to export
                "AWS_ACCESS_KEY_ID": "xxx",
                "AWS_SECRET_ACCESS_KEY": "yyy",
                "AWS_SESSION_TOKEN": "zzz",
            },
            envvars
        )

    def test_apply_sts_json_env(self):
        envvars = apply_sts_json(
            self._sts_json(),
            True,
            "/path/to/creds",
            "mfa",
            False
        )
        self.assertEqual(
            {
                "AWS_ACCESS_KEY_ID": "xxx",
                "AWS_SECRET_ACCESS_KEY": "yyy",
                "AWS_SESSION_TOKEN": "zzz",
            },
            envvars
        )

    @patch('src.aws_cli_mfa.write_config')
    def test_apply_sts_json_config_profile(self, write_config):
        envvars = apply_sts_json(
            self._sts_json(),
            False,
            "/path/to/creds",
            "mfa",
            True
        )
        self.assertEqual(
            {
                "AWS_PROFILE": "mfa",
            },
            envvars
        )

    @patch('src.aws_cli_mfa.write_config')
    def test_apply_sts_json_config(self, write_config):
        envvars = apply_sts_json(
            self._sts_json(),
            False,
            "/path/to/creds",
            "mfa",
            False
        )
        self.assertEqual(
            {
            },
            envvars
        )

    @patch('os.popen')
    @patch('src.aws_cli_mfa.parse_cli_args')
    def test_build_response(self, parse_cli_args, os_popen):
        self.maxDiff = None

        cli_args = self._mock_cli_args(
            profile_arn = 'ARN',
            mfa_token = 'MFA',
            aws_profile = 'pro',
            lifetime_duration = '1234'
        )

        cli_args.aws_env_vars = True
        cli_args.aws_creds_file = "/path/to/creds"
        cli_args.aws_creds_mfa_section = "mfa"
        cli_args.no_export_profile = False

        parse_cli_args.return_value = cli_args

        os_popen.return_value.read.return_value = json.dumps(self._sts_json())

        response = build_response()
        self.assertEqual(
            {
                'sts_cmd': "aws sts get-session-token --profile pro --serial-number ARN --token-code MFA --duration-seconds 1234",
                'envvars': {
                    "AWS_ACCESS_KEY_ID": "xxx",
                    "AWS_SECRET_ACCESS_KEY": "yyy",
                    "AWS_SESSION_TOKEN": "zzz",
                }
            },
            response
        )


if __name__ == '__main__':
    unittest.main()
