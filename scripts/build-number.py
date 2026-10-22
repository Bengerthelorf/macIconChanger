#!/usr/bin/env python3
"""
5MMmmppSNNNFF — ordered Sparkle build number from MARKETING_VERSION.

  1.5.0-alpha.1 -> 5010500100100
  1.5.0-beta.1  -> 5010500300100
  1.5.0-pre.1   -> 5010500500100
  1.5.1-pre.1.fix.3 -> 5010501500103
  1.5.1-pre.2   -> 5010501500200
  1.5.0-rc.1    -> 5010500700100
  1.5.0         -> 5010500900000

The leading 5 migrates new releases above the published 4-prefixed scheme.
Separate sequence and fix fields keep pre.1 < pre.1.fix.3 < pre.2, without
moving hotfixes into the next stage. Published tags retain their original
build numbers and must not be rebuilt. All values fit in a signed 64-bit
integer; fixed-width fields preserve version, stage, sequence, and fix order.
"""

import re
import sys

version = sys.argv[1] if len(sys.argv) > 1 else ""
if not version:
    sys.exit("Usage: build-number.py <marketing-version>")

m = re.fullmatch(
    r"(\d+)\.(\d+)\.(\d+)"
    r"(?:(?:-(alpha|beta|pre|rc)[.-]?(\d+)"
    r"(?:[.-]fix[.-]?(\d+))?)|(?:-(\d+)))?",
    version,
)
if not m:
    sys.exit(f"Cannot parse version: {version}")

major, minor, patch = int(m.group(1)), int(m.group(2)), int(m.group(3))
label = m.group(4)
base_seq = int(m.group(5) or 0)
fix_seq = int(m.group(6)) if m.group(6) is not None else None
seq = int(m.group(7) or base_seq)

if any(component > 99 for component in (major, minor, patch)):
    sys.exit("Major, minor, and patch versions must be between 0 and 99")
stage = {
    "alpha": 1,
    "beta": 3,
    "pre": 5,
    "rc": 7,
    None: 9,
}[label]

if fix_seq is not None:
    if base_seq < 1 or base_seq > 999:
        sys.exit("Hotfix base sequence must be between 1 and 999")
    if fix_seq < 1 or fix_seq > 99:
        sys.exit("Hotfix sequence must be between 1 and 99")

if seq > 999:
    sys.exit("Release sequence must be between 0 and 999")

print(f"5{major:02d}{minor:02d}{patch:02d}{stage}{seq:03d}{fix_seq or 0:02d}")
