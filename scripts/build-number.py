#!/usr/bin/env python3
"""
4MMmmppSNNN — ordered Sparkle build number from MARKETING_VERSION.

  1.5.0-alpha.1 -> 40105001001
  1.5.0-beta.1  -> 40105003001
  1.5.0-pre.1   -> 40105005001
  1.5.1-pre.1.fix.1 -> 40105016101
  1.5.0-rc.1    -> 40105007001
  1.5.0         -> 40105009000

The leading 4 migrates every new build above the currently published
3014470009. The stage digit keeps prereleases below the stable build for
the same marketing version while the fixed-width version components keep
multi-digit minor and patch releases unambiguous.
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
    if base_seq < 1 or base_seq > 9:
        sys.exit("Hotfix base sequence must be between 1 and 9")
    if fix_seq < 1 or fix_seq > 99:
        sys.exit("Hotfix sequence must be between 1 and 99")
    stage += 1
    seq = base_seq * 100 + fix_seq

if seq > 999:
    sys.exit("Release sequence must be between 0 and 999")

print(f"4{major:02d}{minor:02d}{patch:02d}{stage}{seq:03d}")
