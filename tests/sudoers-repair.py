#!/usr/bin/env python3
"""Exercise the generated repair script with all privileged boundaries replaced."""
import hashlib
from pathlib import Path
import re
import subprocess
import tempfile

source = Path("IconChanger/Services/IconManager.swift").read_text()
function = source[source.index("    func configureSudoers("):]
template = function.split('let commands = """', 1)[1].split('"""', 1)[0]
template = template.replace("\\\\", "\\")

with tempfile.TemporaryDirectory(prefix="iconchanger-repair-fixture-") as tmp:
    root = Path(tmp)
    etc = root / "etc"
    (etc / "sudoers.d").mkdir(parents=True)
    (root / "tmp").mkdir()
    helper = root / "helper.sh"
    fileicon = root / "fileicon"
    helper.write_text("fixture helper\n")
    fileicon.write_text("fixture fileicon\n")
    fake_sudo = root / "sudo"
    fake_sudo.write_text(f'''#!/bin/bash
main=$(cat '{etc}/sudoers')
rules="$main"
if printf '%s\\n' "$main" | /usr/bin/grep -Fx '#includedir {etc}/sudoers.d' >/dev/null; then
  if [ -f '{etc}/sudoers.d/iconchanger' ]; then rules="$rules\n$(cat '{etc}/sudoers.d/iconchanger')"; fi
fi
if [ "$1" = '-U' ]; then
  printf '%b\\n' "$rules"
  exit 0
fi
printf '%b\\n' "$rules" | /usr/bin/grep -F 'NOPASSWD: {helper}' >/dev/null
''')
    fake_stat = root / "stat"
    fake_stat.write_text("#!/bin/bash\nprintf 'root:wheel:755\\n'\n")
    fake_visudo = root / "visudo"
    fake_visudo.write_text("#!/bin/bash\nexit 0\n")
    for path in (fake_sudo, fake_stat, fake_visudo):
        path.chmod(0o755)

    begin = "# BEGIN IconChanger managed helper"
    end = "# END IconChanger managed helper"
    rule = f"audit ALL=(root) NOPASSWD: {helper}"
    legacy = f"ALL ALL=(ALL) NOPASSWD: {root}/home/.iconchanger/helper.sh"
    substitutions = {
        "helperPath.shellEscaped": str(helper),
        "fileiconURL.path.shellEscaped": str(fileicon),
        "username.shellEscaped": "audit",
        "sudoersLine.shellEscaped": rule,
        "helperHash": hashlib.sha256(helper.read_bytes()).hexdigest(),
        "fileiconHash": hashlib.sha256(fileicon.read_bytes()).hexdigest(),
        "legacyLines[0].shellEscaped": legacy,
        "legacyLines[1].shellEscaped": legacy.replace("ALL ALL", "audit ALL"),
        "SudoersRulePolicy.managedBlockBegin": begin,
        "SudoersRulePolicy.managedBlockEnd": end,
        "legacyHelperScriptPath.shellEscaped": str(root / "home/.iconchanger/helper.sh"),
        "legacyFileiconPath.shellEscaped": str(root / "home/.iconchanger/fileicon"),
    }

    def repair(initial, compatibility):
        main = etc / "sudoers"
        if main.exists(): main.chmod(0o600)
        main.write_text(initial)
        dropin = etc / "sudoers.d/iconchanger"
        dropin.unlink(missing_ok=True)
        values = {**substitutions, "compatibilityFlag": str(int(compatibility))}
        script = re.sub(r"\\\(([^)]+)\)", lambda m: values[m[1]], template)
        script = script.replace("/private/etc", str(etc))
        script = script.replace("mktemp /tmp/iconchanger-", "mktemp " + str(root / "tmp/iconchanger-"))
        for executable, replacement in {
            "/usr/bin/sudo": str(fake_sudo),
            "/usr/bin/stat": str(fake_stat),
            "/usr/sbin/visudo": str(fake_visudo),
            "/usr/sbin/chown": "/usr/bin/true",
            "/bin/chmod": "/usr/bin/true",
        }.items():
            script = script.replace(executable, replacement)
        assert "/private/etc" not in script
        result = subprocess.run(["/bin/bash", "-c", script], capture_output=True, text=True)
        assert result.returncode == 0, result.stderr
        return result.stdout, main.read_text(), dropin.exists()

    broken_include = f"#includedir {etc}/sudoers.\n{begin}\n{rule}\n{end}\n"
    output, main, dropin = repair(broken_include, False)
    assert "ICONCHANGER_MANAGED_COMPATIBILITY_REQUIRED" in output
    assert main == broken_include and not dropin, "compatibility request must roll back"

    output, main, dropin = repair(broken_include + legacy + "\n", True)
    assert "ICONCHANGER_CONFIGURATION_MODE=main_file" in output
    assert main.count(begin) == 1 and legacy not in main and not dropin

    damaged_rule = f"#includedir {etc}/sudoers.d\n{legacy}d\n"
    output, main, dropin = repair(damaged_rule, False)
    assert "ICONCHANGER_UNRECOGNIZED_LEGACY_RULE" in output
    assert main == damaged_rule and not dropin, "unrecognized rules must be preserved"

    normal = f"#includedir {etc}/sudoers.d\n{legacy}\n"
    output, main, dropin = repair(normal, False)
    assert "ICONCHANGER_CONFIGURATION_MODE=drop_in" in output
    assert legacy not in main and dropin

print("PASS: repair handles stale compatibility blocks, malformed legacy rules, and rollback")
