#!/usr/bin/env python3
"""
30VVVTTNNN — semantic build number from MARKETING_VERSION.

  1.4.5       -> 3014500000
  1.4.5-3     -> 3014500003
  1.4.5-pre-1 -> 3014570001
"""

import re, sys

version = sys.argv[1] if len(sys.argv) > 1 else ""
if not version:
    sys.exit("Usage: build-number.py <marketing-version>")

m = re.match(r'^(\d+)\.(\d+)\.(\d+)(?:-(pre)-?(\d+)|(?:-(\d+)))?$', version)
if not m:
    sys.exit(f"Cannot parse version: {version}")

major, minor, patch = int(m.group(1)), int(m.group(2)), int(m.group(3))
is_pre = m.group(4) == "pre"
seq = int(m.group(5) or m.group(6) or 0)

vvv = major * 100 + minor * 10 + patch
# TT=70 for pre so pre builds always outrank stable patches within the same version
tt = 70 if is_pre else 0

print(f"30{vvv:03d}{tt:02d}{seq:03d}")
