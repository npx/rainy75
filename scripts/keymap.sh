#!/bin/sh
# Keep one product-neutral VIA keymap export and derive the per-link copies.
#
#   scripts/keymap.sh normalize   strip vendorProductId from the base, pretty-print
#   scripts/keymap.sh build       write dist/<base>-usb and -2.4g with the id set
#   scripts/keymap.sh check       exit 1 if dist/ does not match what build would write
#
# The base may or may not carry a vendorProductId (it does right after you save
# an export over it from usevia.app); every command tolerates both states.
# Requires jq.
set -eu

cd "$(dirname "$0")/.."
BASE=rainy_75_jis.layout.json
DIST=dist
STEM=${BASE%.layout.json}

VENDOR=0x320F
# link name -> product id, same as in vendor/*.json
VARIANTS="usb:0x5055 2.4g:0x5088"

command -v jq >/dev/null 2>&1 || { echo "keymap.sh: jq is required" >&2; exit 2; }
[ -f "$BASE" ] || { echo "keymap.sh: $BASE not found, export it from usevia.app first (Save + Load -> Save)" >&2; exit 0; }

neutral() {            # base without vendorProductId, normalized formatting
  jq 'del(.vendorProductId)' "$BASE"
}

variant() {            # $1 = link, $2 = product id -> stdout
  id=$(( (VENDOR << 16) | $2 ))
  neutral | jq --argjson id "$id" '{name, vendorProductId: $id} + .'
}

render() {             # write all variants into directory $1
  for v in $VARIANTS; do
    link=${v%%:*}; pid=${v#*:}
    variant "$link" "$pid" > "$1/$STEM-$link.layout.json"
  done
}

case "${1:-}" in
  normalize)
    tmp=$(mktemp "$BASE.XXXXXX")
    neutral > "$tmp" && mv "$tmp" "$BASE"
    ;;
  build)
    mkdir -p "$DIST"
    render "$DIST"
    ;;
  check)
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    render "$tmp"
    rc=0
    for f in "$tmp"/*; do
      name=$(basename "$f")
      if [ ! -f "$DIST/$name" ]; then
        echo "check: $DIST/$name missing (run scripts/keymap.sh build)" >&2; rc=1
      elif ! cmp -s "$f" "$DIST/$name"; then
        echo "check: $DIST/$name differs from $BASE (run scripts/keymap.sh build)" >&2; rc=1
      fi
    done
    [ $rc -eq 0 ] && echo "check: dist/ matches $BASE"
    exit $rc
    ;;
  *)
    sed -n '2,8p' "$0" >&2; exit 2
    ;;
esac
