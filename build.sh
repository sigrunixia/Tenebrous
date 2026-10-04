#!/usr/bin/env bash
# Build the Tenebrous theme for one or more targets, then deploy the results.
#
#   ./build.sh                 Obsidian target (the default)
#   ./build.sh --obsidian      build the Obsidian theme, snippets and Publish files
#   ./build.sh --zed           generate and validate the Zed theme and copy it to ~/.config/zed/themes
#   ./build.sh --all           every target
#   ./build.sh --publish       with Obsidian, also push publish.css and publish.js to Obsidian Publish
#   ./build.sh --build-only    build only, deploy nothing
#
# Only publish.css and publish.js are ever pushed to the live site, and only
# with --publish. Published notes are not touched; publish those on their own.
# Colours live in palette.json; every run regenerates src/_palette.scss in the
# Obsidian repo and themes/tenebrous.json in the Zed repo from it. Edit
# templates/zed.template.json, not the generated JSON.
# OBSIDIAN_REPO overrides the Tenebrous-Obsidian repo, ZED_REPO the
# Tenebrous-Zed repo, VAULT the vault path, VAULT_NAME the Obsidian CLI vault
# name, ZED_THEMES the Zed themes folder.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
DIR="${OBSIDIAN_REPO:-/Users/Signia/Developer/Tenebrous-Obsidian}"
ZED_THEMES="${ZED_THEMES:-$HOME/.config/zed/themes}"
ZED_REPO="${ZED_REPO:-/Users/Signia/Developer/Tenebrous-Zed}"
VAULT="${VAULT:-/Users/Signia/Vaults/Tenebrous}"
VAULT_NAME="${VAULT_NAME:-Tenebrous}"

DEPLOY=1
PUBLISH=0
OBSIDIAN=0
ZED=0
for arg in "$@"; do
  case "$arg" in
    --obsidian)   OBSIDIAN=1 ;;
    --zed)        ZED=1 ;;
    --all)        OBSIDIAN=1; ZED=1 ;;
    --publish)    PUBLISH=1 ;;
    --build-only) DEPLOY=0 ;;
    *) echo "Unknown option: $arg" >&2; echo "Usage: build.sh [--obsidian] [--zed] [--all] [--publish] [--build-only]" >&2; exit 2 ;;
  esac
done

if [ "$OBSIDIAN" = 0 ] && [ "$ZED" = 0 ]; then
  OBSIDIAN=1
fi

if [ "$PUBLISH" = 1 ] && { [ "$DEPLOY" = 0 ] || [ "$OBSIDIAN" = 0 ]; }; then
  echo "--publish needs the Obsidian target and the deploy step." >&2
  exit 2
fi

build_palette() {
  OBSIDIAN_REPO="$DIR" ZED_REPO="$ZED_REPO" python3 "$HERE/build-palette.py"
  echo "Generated palette files from palette.json"
}

build_zed() {
  python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$ZED_REPO/themes/tenebrous.json"
  echo "Checked $ZED_REPO/themes/tenebrous.json"
  [ "$DEPLOY" = 1 ] || return 0
  mkdir -p "$ZED_THEMES"
  cp "$ZED_REPO/themes/tenebrous.json" "$ZED_THEMES/tenebrous.json"
  echo "Deployed to $ZED_THEMES"
}

build_obsidian() {
# Build
sass --no-source-map "$DIR/src/main.scss" "$DIR/theme.css"
echo "Built theme.css"
sass --no-source-map "$DIR/src/main-publish.scss" "$DIR/publish.css"
echo "Built publish.css"
sass --no-source-map "$DIR/src/main-landing-snippet.scss" "$DIR/landing-preview.css"
echo "Built landing-preview.css"
sass --no-source-map "$DIR/src/main-contact-snippet.scss" "$DIR/contact-preview.css"
echo "Built contact-preview.css"

cp "$DIR/src/publish.js" "$DIR/publish.js"
node "$DIR/build-index.js" "$VAULT" >/dev/null
echo "Built publish.js"

[ "$DEPLOY" = 1 ] || return 0

# Deploy. The vault keeps its own manifest.json, so only theme.css is copied
# into the theme folder.
if [ ! -d "$VAULT/.obsidian" ]; then
  echo "No vault at $VAULT, skipping deploy." >&2
  return 1
fi

cp "$DIR/theme.css"           "$VAULT/.obsidian/themes/Tenebrous/theme.css"
cp "$DIR/landing-preview.css" "$VAULT/.obsidian/snippets/landing-preview.css"
cp "$DIR/contact-preview.css" "$VAULT/.obsidian/snippets/contact-preview.css"
cp "$DIR/publish.css"         "$VAULT/publish.css"
cp "$DIR/publish.js"          "$VAULT/publish.js"
echo "Deployed to $VAULT (theme, snippets, publish.css, publish.js)"

if [ "$PUBLISH" = 1 ]; then
  for f in publish.css publish.js; do
    obsidian publish:add vault="$VAULT_NAME" file="$f"
  done
fi
}

build_palette
[ "$OBSIDIAN" = 0 ] || build_obsidian
[ "$ZED" = 0 ] || build_zed
