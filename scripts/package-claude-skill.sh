#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT/skills/ticket-manager"
DIST="$ROOT/dist"
OUTPUT="$DIST/ticket-manager.skill.zip"

if [[ ! -f "$SOURCE/SKILL.md" ]]; then
  echo "Missing required skill file: $SOURCE/SKILL.md" >&2
  exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "Missing required tool: zip" >&2
  exit 1
fi

mkdir -p "$DIST"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/ticket-manager"
cp "$SOURCE/SKILL.md" "$tmp/ticket-manager/SKILL.md"
if [[ -d "$SOURCE/references" ]]; then
  cp -R "$SOURCE/references" "$tmp/ticket-manager/references"
fi
if [[ -d "$SOURCE/scripts" ]]; then
  cp -R "$SOURCE/scripts" "$tmp/ticket-manager/scripts"
fi
if [[ -d "$SOURCE/assets" ]]; then
  cp -R "$SOURCE/assets" "$tmp/ticket-manager/assets"
fi

rm -f "$OUTPUT"
(
  cd "$tmp"
  zip -q -r "$OUTPUT" ticket-manager
)

echo "$OUTPUT"
unzip -t "$OUTPUT" >/dev/null
unzip -l "$OUTPUT"
