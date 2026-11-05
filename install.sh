#!/bin/bash

# Install (or update) the wifi-forget plugin into the Omarchy shell.
# Uninstall with: omarchy plugin remove johnny.wifi-forget --yes

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ID=$(jq -r .id "$SRC_DIR/manifest.json")
TARGET="$HOME/.config/omarchy/plugins/$ID"
FILES=(manifest.json Panel.qml Model.js)

omarchy-plugin-validate "$SRC_DIR"

mkdir -p "$TARGET"
for file in "${FILES[@]}"; do
  install -m 644 "$SRC_DIR/$file" "$TARGET/$file"
done

omarchy-shell shell rescanPlugins >/dev/null

enabled=$(omarchy-shell shell listPlugins | jq -r --arg id "$ID" '.[] | select(.id == $id) | .enabled')
if [[ $enabled != "true" ]]; then
  # Discovery is asynchronous after a rescan; give it a moment before enabling.
  for (( attempt = 0; attempt < 40; attempt++ )); do
    omarchy-plugin-list --json | jq -e --arg id "$ID" 'any(.[]; .id == $id)' >/dev/null && break
    sleep 0.05
  done
  omarchy-plugin-enable "$ID" >/dev/null
fi

echo "Installed $ID to $TARGET (replaces omarchy.network in the bar)"
