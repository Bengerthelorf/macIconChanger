#!/usr/bin/env python3

import sys
import xml.etree.ElementTree as ET


if len(sys.argv) != 7:
    raise SystemExit(
        "Usage: validate-appcast.py <xml> <version> <build> "
        "<signature> <size> <download-url>"
    )

xml_path, version, build, signature, size, download_url = sys.argv[1:]
namespaces = {"sparkle": "http://www.andymatuschak.org/xml-namespaces/sparkle"}
root = ET.parse(xml_path).getroot()

for item in root.findall("./channel/item"):
    short_version = item.findtext("sparkle:shortVersionString", namespaces=namespaces)
    if short_version != version:
        continue

    actual_build = item.findtext("sparkle:version", namespaces=namespaces)
    enclosure = item.find("enclosure")
    if enclosure is None:
        raise SystemExit(f"Version {version} has no enclosure")

    ed_key = f"{{{namespaces['sparkle']}}}edSignature"
    checks = {
        "build": (actual_build, build),
        "signature": (enclosure.attrib.get(ed_key), signature),
        "size": (enclosure.attrib.get("length"), size),
        "download URL": (enclosure.attrib.get("url"), download_url),
    }
    failures = [
        f"{name}: expected {expected!r}, found {actual!r}"
        for name, (actual, expected) in checks.items()
        if actual != expected
    ]
    if failures:
        raise SystemExit("; ".join(failures))

    print(f"Appcast entry for {version} is internally consistent.")
    break
else:
    raise SystemExit(f"Version {version} was not found in the appcast")
