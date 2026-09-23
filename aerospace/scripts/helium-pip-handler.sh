#!/bin/bash
# Helium window handler for AeroSpace.
#
# Why this exists: Google Meet (and other sites) use the Document
# Picture-in-Picture API. Chromium titles those windows with the plain page
# title -- e.g. "Meet - abc-defg-hij" -- never "Picture in Picture". So the
# window-title-regex-substring rules in .aerospace.toml structurally cannot
# catch them, and they get tiled and routed away like a normal window.
#
# The signal that actually works: real Helium browser windows always have the
# app name appended to their title (" - Helium"). PiP windows (and Chromium
# app/PWA windows) do not.
#
# Flow:
#   1. Title says "Picture in Picture" outright -> float, leave in place.
#   2. Title ends with " - Helium" -> normal window, tile + workspace 1. Instant,
#      no waiting, so ordinary browsing has no visible lag.
#   3. Ambiguous (empty or no suffix yet) -> do nothing, poll briefly. If the
#      suffix shows up it was just a slow-loading normal window. If it never
#      does, treat it as PiP: float it and leave it on the workspace it was born
#      on, so Helium keeps its bottom-right placement.
#
# Set HELIUM_PIP_DEBUG=1 to trace decisions to $LOG_FILE.

set -uo pipefail

AEROSPACE="/opt/homebrew/bin/aerospace"
WIN_ID="${AEROSPACE_WINDOW_ID:-}"
HOME_WORKSPACE=1
APP_SUFFIX=" - Helium"
POLL_INTERVAL=0.1
POLL_ATTEMPTS=15 # ~1.5s before an untitled window is declared PiP

LOG_FILE="${TMPDIR:-/tmp}/helium-pip-handler.log"
log() {
    [[ "${HELIUM_PIP_DEBUG:-0}" == "1" ]] || return 0
    echo "$(date '+%H:%M:%S') [$WIN_ID] $*" >>"$LOG_FILE"
}

[[ -z "$WIN_ID" ]] && exit 0

# Explicit PiP titles, for apps/sites that do set them.
PIP_REGEX='[Pp]icture[[:space:]_-]*[Ii]n[[:space:]_-]*[Pp]icture'

# Echoes "<workspace>\t<title>" for WIN_ID, or nothing if the window is gone.
window_info() {
    "$AEROSPACE" list-windows --all --format '%{window-id}%{tab}%{workspace}%{tab}%{window-title}' 2>/dev/null |
        awk -F '\t' -v id="$WIN_ID" '$1 == id { print $2 "\t" $3; exit }'
}

float_in_place() {
    local workspace="$1"
    # Never tile or resize: the browser positions PiP itself (bottom-right).
    "$AEROSPACE" layout floating --window-id "$WIN_ID" 2>/dev/null || true
    if [[ -n "$workspace" ]]; then
        local current
        current=$(window_info)
        current="${current%%$'\t'*}"
        if [[ -n "$current" && "$current" != "$workspace" ]]; then
            "$AEROSPACE" move-node-to-workspace "$workspace" --window-id "$WIN_ID" 2>/dev/null || true
        fi
    fi
}

send_home() {
    "$AEROSPACE" layout tiling --window-id "$WIN_ID" 2>/dev/null || true
    "$AEROSPACE" move-node-to-workspace "$HOME_WORKSPACE" --window-id "$WIN_ID" 2>/dev/null || true
}

info=$(window_info)
[[ -z "$info" ]] && exit 0

origin_workspace="${info%%$'\t'*}"
title="${info#*$'\t'}"
log "detected on ws=$origin_workspace title=[$title]"

# Case 1: explicitly titled as PiP.
if [[ "$title" =~ $PIP_REGEX ]]; then
    log "explicit PiP title -> floating on ws=$origin_workspace"
    float_in_place "$origin_workspace"
    exit 0
fi

# Case 2: has the app-name suffix -> ordinary browser window. Act immediately.
if [[ "$title" == *"$APP_SUFFIX" ]]; then
    log "normal window -> tiling to ws=$HOME_WORKSPACE"
    send_home
    exit 0
fi

# Case 3: ambiguous. Leave the window untouched while we wait for a verdict --
# doing nothing here is what keeps a PiP window from flashing over to ws 1.
for _ in $(seq "$POLL_ATTEMPTS"); do
    sleep "$POLL_INTERVAL"
    info=$(window_info)
    [[ -z "$info" ]] && exit 0 # window closed
    title="${info#*$'\t'}"
    if [[ "$title" =~ $PIP_REGEX ]]; then
        log "late explicit PiP title -> floating on ws=$origin_workspace"
        float_in_place "$origin_workspace"
        exit 0
    fi
    if [[ "$title" == *"$APP_SUFFIX" ]]; then
        log "late normal window [$title] -> tiling to ws=$HOME_WORKSPACE"
        send_home
        exit 0
    fi
done

# Never gained the app suffix -> PiP (or a Chromium app window). Float, stay put.
log "no app suffix after watch window -> PiP, floating on ws=$origin_workspace"
float_in_place "$origin_workspace"
exit 0
