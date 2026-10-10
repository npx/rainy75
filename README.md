# Rainy 75 Pro JIS (Wobkey) — keymap without vendor software

The board runs VIA-compatible firmware (USB 320f:5055 wired, 320f:5088 via
the 2.4G dongle). Remapping is done in the browser at https://usevia.app
(Chrome, WebHID). VIA reads the keymap from the board's own storage and
writes changes straight back; nothing here flashes firmware.

## Linux prerequisite
hidraw nodes are root-only; the dotfiles add a udev rule
(`modules/nixos/desktop.nix`, 70-rainy75.rules, TAG+="uaccess").
Rebuild, then re-plug the dongle / cable.

## Definitions (`vendor/`, never edited)
`rainy75-jis-2.4g.json` (dongle, PID 5088) and `rainy75-jis-usb.json`
(wired, PID 5055). Official files, dated 2026-05-28, obtained from the
Japanese distributor KIBU (Wobkey's own site does not list them). The two
differ only in the product id.

usevia.app: Settings → "Show Design tab" → Design → "Load Draft Definition",
select both files at once. Drafts are kept in the browser only; load them
again after clearing site data.

## Keymap
`rainy_75_jis.layout.json` is the tracked keymap (VIA "Save + Load" export)
with the `vendorProductId` removed, so it is the same file whether the board
is on the dongle or the cable. `dist/` holds the two loadable copies with the
id filled in; it is generated and gitignored.

Once per clone (needs `jq`):

    ./setup.sh

Edit cycle:

1. usevia.app → Save + Load → **Load** `dist/rainy_75_jis-usb.layout.json`
   or `dist/rainy_75_jis-2.4g.layout.json`, whichever link is active.
   VIA refuses the other one ("created for a different keyboard").
2. Remap in the Configure tab. Changes are live on the board.
3. Save + Load → **Save**. Chrome suggests `rainy_75_jis.layout.json`; save it
   into this folder, overwriting the base file.
4. Commit. The pre-commit hook strips the id, pretty-prints one keycode per
   line, re-stages the file and rebuilds `dist/`. Checkout and merge rebuild
   `dist/` too.

`scripts/keymap.sh check` verifies `dist/` against the base. Never edit
`dist/` by hand; it is overwritten on every commit.
