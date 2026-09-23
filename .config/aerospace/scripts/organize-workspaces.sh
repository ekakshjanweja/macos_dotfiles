#!/bin/bash
# aerospace-reset: move every mapped window to its home AeroSpace workspace.
# Installed as `aerospace-reset` on PATH (symlink in ~/.local/bin).
#
# Usage: aerospace-reset [--dry-run] [--quiet]
# Exit codes: 0 ok, 1 AeroSpace unreachable, 2 bad usage.
#
# Edit home_for() to change the mapping. Find bundle IDs with:
#   aerospace list-windows --all --format '%{app-name} | %{app-bundle-id}' | sort -u

set -uo pipefail

AEROSPACE="/opt/homebrew/bin/aerospace"
APP_SUFFIX=" - Helium" # same signal as helium-pip-handler.sh

DRY_RUN="${DRY_RUN:-0}"
QUIET=0
for arg in "$@"; do
    case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --quiet | -q) QUIET=1 ;;
    -h | --help)
        echo "usage: aerospace-reset [--dry-run] [--quiet]"
        exit 0
        ;;
    *)
        echo "aerospace-reset: unknown option '$arg' (try --help)" >&2
        exit 2
        ;;
    esac
done

say() { [[ "$QUIET" == "1" ]] || echo "$*"; }

if ! "$AEROSPACE" list-workspaces --all >/dev/null 2>&1; then
    echo "aerospace-reset: can't reach AeroSpace. Is AeroSpace.app running?" >&2
    exit 1
fi

home_for() {
    local bundle="$1" title="$2"
    case "$bundle" in
    net.imput.helium)
        # Skip Helium PiP windows (no " - Helium" marker anywhere in the
        # title): leave them floating where they are instead of dragging
        # them to workspace 1.
        [[ "$title" == *"$APP_SUFFIX"* ]] || return 1
        echo 1
        ;;
    com.cmuxterm.app | com.mitchellh.ghostty) echo 2 ;;
    com.todesktop.230313mzl4w4u92) echo 3 ;; # Cursor
    # Add more below, e.g. com.spotify.client) echo 4 ;;
    # Bundle IDs observed on your machine:
    #   net.whatsapp.WhatsApp  (WhatsApp)
    #   com.apple.MobileSMS    (Messages)
    #   com.anysphere.sand     (Grok Bot)
    #   com.t3tools.t3code     (T3 Code Alpha)
    *) return 1 ;;
    esac
}

moved=0
already=0
skipped=0
while IFS=$'\t' read -r wid app bundle ws title; do
    [[ -n "${wid:-}" ]] || continue
    target=$(home_for "$bundle" "${title:-}") || {
        skipped=$((skipped + 1))
        continue
    }
    if [[ "$ws" == "$target" ]]; then
        already=$((already + 1))
        continue
    fi
    if [[ "$DRY_RUN" == "1" ]]; then
        say "would move ${app:-window $wid} (id $wid) ws $ws -> $target"
    else
        if "$AEROSPACE" move-node-to-workspace "$target" --window-id "$wid" 2>/dev/null; then
            say "moved ${app:-window $wid} (id $wid) ws $ws -> $target"
        else
            say "FAILED to move ${app:-window $wid} (id $wid) ws $ws -> $target"
            continue
        fi
    fi
    moved=$((moved + 1))
done < <("$AEROSPACE" list-windows --all --format '%{window-id}%{tab}%{app-name}%{tab}%{app-bundle-id}%{tab}%{workspace}%{tab}%{window-title}' 2>/dev/null |
    sort -t "$(printf '\t')" -k1,1n)

if [[ "$moved" -eq 0 ]]; then
    say "already organized ($already already home, $skipped unmapped)"
else
    say "done: $moved moved, $already already home, $skipped unmapped"
fi
