#!/usr/bin/env python3

import sys

options = {
    "usage": "usage instructions",
    "notjson": "not json",
    "sts": '{"sts_cmd": "aws sts something something"}',
    "output": '{"sts_cmd": "aws sts something something", "output": "output across\\\\nmultiple lines"}',
    "envvars": '{"sts_cmd": "sts", "output": "output", "envvars": {"TEST_AWS_CLI_MFA_1": "val1", "TEST_AWS_CLI_MFA_2": "val2"}}',
}

if len(sys.argv) > 1:
    output = options.get(sys.argv[1])
    if output:
        print(output)
    else:
        print("FAILED: invalid arg given")
else:
    print("FAILED: no arg given")
    exit(1)
