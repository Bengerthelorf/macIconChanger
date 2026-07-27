#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="${1:-}"
OUTPUT_DMG="${2:-}"

if [[ -z "$APP_PATH" || -z "$OUTPUT_DMG" ]]; then
    echo "Usage: $0 <IconChanger.app> <output.dmg>" >&2
    exit 1
fi

[[ -d "$APP_PATH" ]] || {
    echo "App bundle does not exist: $APP_PATH" >&2
    exit 1
}

[[ "$APP_PATH" == *.app ]] || {
    echo "Input must be an .app bundle: $APP_PATH" >&2
    exit 1
}

[[ ! -e "$OUTPUT_DMG" ]] || {
    echo "Refusing to overwrite existing DMG: $OUTPUT_DMG" >&2
    exit 1
}

command -v dmgbuild >/dev/null || {
    echo "dmgbuild 1.6.7 is required." >&2
    exit 1
}

BACKGROUND="$PROJECT_DIR/assets/dmg/background.png"
RETINA_BACKGROUND="$PROJECT_DIR/assets/dmg/background@2x.png"
[[ -f "$BACKGROUND" ]] || {
    echo "DMG background is missing: $BACKGROUND" >&2
    exit 1
}
[[ -f "$RETINA_BACKGROUND" ]] || {
    echo "Retina DMG background is missing: $RETINA_BACKGROUND" >&2
    exit 1
}

mkdir -p "$(dirname "$OUTPUT_DMG")"
dmgbuild \
    -s "$PROJECT_DIR/scripts/dmg-settings.py" \
    -D "app=$APP_PATH" \
    -D "background=$BACKGROUND" \
    "IconChanger" \
    "$OUTPUT_DMG"

hdiutil verify "$OUTPUT_DMG"
