#!/usr/bin/env python3

import sys
import json

options = {
    "usage": "usage instructions",
    "notjson": "not json",
    "sts": json.dumps({"sts_cmd": "aws sts something something"}),
    "output": json.dumps({"sts_cmd": "aws sts something something", "output": "output across\nmultiple lines"}),
    "envvars": json.dumps({"sts_cmd": "sts", "output": "output", "envvars": {"TEST_AWS_CLI_MFA_1": "val1", "TEST_AWS_CLI_MFA_2": "val2"}}),
}

# test = {"output": """output across
# multiple lines"""}
# # both become: "output across\nmultiple lines"
# print(json.dumps(test))
# print(test)

if len(sys.argv) > 1:
    output = options.get(sys.argv[1], "FAILED: invalid arg given")
    print(output)
else:
    print("FAILED: no arg given")
    exit(1)
