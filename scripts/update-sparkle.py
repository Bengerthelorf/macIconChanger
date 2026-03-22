#!/usr/bin/env python3
"""Update sparkle.xml with release info from CI environment variables."""

import sys, re, os

version = os.environ["SPARKLE_VERSION"]
build = os.environ["SPARKLE_BUILD"]
pubdate = os.environ["SPARKLE_PUBDATE"]
download_url = os.environ["SPARKLE_DOWNLOAD_URL"]
ed_sig = os.environ["SPARKLE_ED_SIG"]
dmg_size = os.environ["SPARKLE_DMG_SIZE"]
repo = os.environ["SPARKLE_REPO"]
is_prerelease = os.environ.get("SPARKLE_IS_PRERELEASE", "false") == "true"

changelog_html = ""
try:
    with open("CHANGELOG.md") as f:
        lines = f.readlines()
    items = []
    prefix_map = {
        "feat:": "New:", "fix:": "Fixed:", "perf:": "Perf:",
        "docs:": "Docs:", "refactor:": "Refactor:"
    }
    for line in lines:
        line = line.strip()
        if not line.startswith("- "):
            continue
        msg = line[2:]
        if msg.startswith(("release:", "chore:", "Merge ")):
            continue
        formatted = None
        for prefix, label in prefix_map.items():
            if msg.startswith(prefix):
                formatted = f"<li><strong>{label}</strong> {msg[len(prefix):].strip()}</li>"
                break
        items.append(formatted or f"<li>{msg}</li>")
    if items:
        changelog_html = "\n".join(f"                        {i}" for i in items)
except Exception:
    pass

desc_block = ""
if changelog_html:
    desc_block = (
        "\n                    <description>\n"
        "                        <![CDATA[\n"
        f"                    <h2>Version {version}</h2>\n"
        "                    <ul>\n"
        f"{changelog_html}\n"
        "                    </ul>\n"
        "                        ]]>\n"
        "                    </description>"
    )

channel_tag = f"\n                    <sparkle:channel>beta</sparkle:channel>" if is_prerelease else ""

new_item = (
    f"        <item>\n"
    f"                    <title>Version {version}</title>\n"
    f"                    <link>https://github.com/{repo}</link>\n"
    f"                    <sparkle:version>{build}</sparkle:version>\n"
    f"                    <sparkle:shortVersionString>{version}</sparkle:shortVersionString>\n"
    f"                    <pubDate>{pubdate}</pubDate>{channel_tag}\n"
    f'                    <enclosure url="{download_url}"\n'
    f'                    sparkle:edSignature="{ed_sig}" length="{dmg_size}"\n'
    f'                    type="application/octet-stream"/>{desc_block}\n'
    f"                </item>"
)

with open("IconChanger/Resources/sparkle.xml") as f:
    xml = f.read()

existing = re.search(
    r'<item>\s*<title>Version ' + re.escape(version) + r'</title>.*?</item>',
    xml, flags=re.DOTALL
)

if existing:
    item = existing.group(0)

    if 'enclosure' in item:
        main_enc = re.search(r'<enclosure url="[^"]*IconChanger\.dmg".*?/>', item, re.DOTALL)
        if main_enc:
            new_enc = (
                f'<enclosure url="{download_url}"\n'
                f'                    sparkle:edSignature="{ed_sig}" length="{dmg_size}"\n'
                f'                    type="application/octet-stream"/>'
            )
            item = item[:main_enc.start()] + new_enc + item[main_enc.end():]
        item = re.sub(r'<sparkle:version>[^<]*</sparkle:version>', f'<sparkle:version>{build}</sparkle:version>', item)
        item = re.sub(r'<pubDate>[^<]*</pubDate>', f'<pubDate>{pubdate}</pubDate>', item, count=1)
    else:
        enc = (
            f'\n                    <pubDate>{pubdate}</pubDate>'
            f'\n                    <enclosure url="{download_url}"'
            f'\n                    sparkle:edSignature="{ed_sig}" length="{dmg_size}"'
            f'\n                    type="application/octet-stream"/>'
        )
        if '</description>' in item:
            item = item.replace('</description>\n                </item>', '</description>' + enc + '\n                </item>')
        else:
            item = item.replace('</item>', enc + '\n                </item>')
        item = re.sub(r'<sparkle:version>[^<]*</sparkle:version>', f'<sparkle:version>{build}</sparkle:version>', item)

    xml = xml[:existing.start()] + item + xml[existing.end():]
    print(f"Updated existing entry for {version}.")
else:
    marker = '<title>IconChanger</title>'
    idx = xml.find(marker)
    if idx == -1:
        sys.exit('marker not found')
    insert_pos = xml.index('\n', idx) + 1
    xml = xml[:insert_pos] + new_item + '\n' + xml[insert_pos:]
    print(f"Created new entry for {version}.")

# Inject delta entries
try:
    generated = open("build/deltas/generated-appcast.xml").read()
    deltas_match = re.search(
        r'<sparkle:shortVersionString>' + re.escape(version) + r'</sparkle:shortVersionString>'
        r'.*?(<sparkle:deltas>.*?</sparkle:deltas>)',
        generated, flags=re.DOTALL
    )
    if deltas_match:
        deltas_block = deltas_match.group(1)
        current = re.search(
            r'(<item>\s*<title>Version ' + re.escape(version) + r'</title>.*?)(</item>)',
            xml, flags=re.DOTALL
        )
        if current and '<sparkle:deltas>' not in current.group(0):
            xml = xml[:current.end(1)] + "\n                    " + deltas_block + xml[current.end(1):]
            print(f"Injected deltas for {version}.")
except FileNotFoundError:
    pass

with open("IconChanger/Resources/sparkle.xml", "w") as f:
    f.write(xml)
