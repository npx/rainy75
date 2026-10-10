#!/bin/sh
# One-time per clone: git never installs hooks by itself.
# Checks dependencies, points git at .githooks/, builds dist/.
set -eu
cd "$(dirname "$0")"

missing=0
for dep in git jq; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    echo "setup: '$dep' not found" >&2
    missing=1
  fi
done
if [ $missing -ne 0 ]; then
  cat >&2 <<'HINT'
Install the missing tools and run ./setup.sh again:
  macOS:  brew install jq
  Debian: sudo apt install jq
  NixOS:  nix-shell -p jq   (or add jq to your configuration)
HINT
  exit 1
fi

[ -d .git ] || { echo "setup: run this inside the cloned repo (.git not found)" >&2; exit 1; }

git config core.hooksPath .githooks
echo "setup: hooks installed ($(git config core.hooksPath))"
scripts/keymap.sh build
echo "setup: done"
