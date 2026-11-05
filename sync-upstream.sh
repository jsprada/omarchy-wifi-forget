#!/bin/bash

# Rebuild Panel.qml and Model.js from the network panel shipped with the
# installed Omarchy, then re-apply forget.patch. Run after an Omarchy update
# changes the stock panel, then ./install.sh to deploy.

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPSTREAM="${OMARCHY_PATH:-/usr/share/omarchy}/shell/plugins/panels/network"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cp "$UPSTREAM/Panel.qml" "$UPSTREAM/Model.js" "$work/"
if ! patch -d "$work" -p1 --no-backup-if-mismatch <"$SRC_DIR/forget.patch"; then
  echo "sync-upstream: forget.patch no longer applies cleanly; update it by hand" >&2
  exit 1
fi

cp "$work/Panel.qml" "$work/Model.js" "$SRC_DIR/"
echo "Rebuilt Panel.qml and Model.js from $UPSTREAM"
