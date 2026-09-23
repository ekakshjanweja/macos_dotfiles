#!/bin/bash
# Fully restart AeroSpace (heavier than reload-config).
# Bound to shift-r in service mode. Existing windows are re-scanned on launch,
# so on-window-detected rules re-apply.

osascript -e 'quit app "AeroSpace"' >/dev/null 2>&1 || killall AeroSpace >/dev/null 2>&1
sleep 1
open -a AeroSpace
