#!/usr/bin/env python3
"""Select a usable Apple Development identity from security(1) output."""

import argparse
import re
import sys


parser = argparse.ArgumentParser()
parser.add_argument(
    "--mode",
    choices=("auto", "apple-development", "adhoc"),
    required=True,
)
args = parser.parse_args()

if args.mode == "adhoc":
    print("-")
    raise SystemExit

identity_pattern = re.compile(
    r'^\s*\d+\)\s+([0-9A-Fa-f]{40})\s+"Apple Development:[^"]+"\s*$'
)

for line in sys.stdin:
    match = identity_pattern.match(line)
    if match:
        print(match.group(1).upper())
        raise SystemExit

if args.mode == "auto":
    print("-")
else:
    sys.exit("No valid Apple Development signing identity was found")
