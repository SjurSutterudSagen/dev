#!/bin/bash

# Define monitor descriptions to match against hyprctl output
PRIMARY_DESC="ASUSTek COMPUTER INC PG32UCDM S6LMQS020784"
SECONDARY_DESC="GIGA-BYTE TECHNOLOGY CO. LTD. Gigabyte M32U 0x01010101"

# Exit codes
EXIT_MISSING_DEPS=2
EXIT_NO_MONITORS=3
EXIT_HYPRCTL_FAILED=4

if ! command -v hyprctl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    echo "Error: Missing dependency. Requires hyprctl and jq." >&2

    exit $EXIT_MISSING_DEPS
fi

monitor_exists_by_desc() {
    hyprctl monitors -j 2>/dev/null | jq -e --arg desc "$1" 'any(.description==$desc)' >/dev/null
}

# Helper: check whether a monitor is enabled (missing/disabled -> false)
is_enabled_by_desc() {
    local desc="$1"
    hyprctl monitors -j 2>/dev/null | jq -e --arg desc "$desc" '
        map(select(.description==$desc)) as $m
        | ($m | length) > 0 and ($m[0].disabled // false | not)
    ' >/dev/null
}

PRIMARY_TARGET="desc:$PRIMARY_DESC"
SECONDARY_TARGET="desc:$SECONDARY_DESC"

if ! monitor_exists_by_desc "$PRIMARY_DESC" && ! monitor_exists_by_desc "$SECONDARY_DESC"; then
    echo "Warning: No matching monitors found for the configured descriptions."
    
    exit $EXIT_NO_MONITORS
fi

PRIMARY_ON=false
SECONDARY_ON=false

if is_enabled_by_desc "$PRIMARY_DESC"; then
    PRIMARY_ON=true
fi
if is_enabled_by_desc "$SECONDARY_DESC"; then
    SECONDARY_ON=true
fi

if [ "$PRIMARY_ON" = true ] && [ "$SECONDARY_ON" = true ]; then
    # Both are on -> disable primary
    hyprctl keyword monitor "$PRIMARY_TARGET,disabled" >/dev/null || exit $EXIT_HYPRCTL_FAILED
    hyprctl keyword monitor "$SECONDARY_TARGET,preferred,auto-left,1.5" >/dev/null || exit $EXIT_HYPRCTL_FAILED

    echo "Switch to secondary monitor only"
elif [ "$PRIMARY_ON" = true ] || [ "$SECONDARY_ON" = true ]; then
    # Only one is on -> enable/configure both
    hyprctl keyword monitor "$PRIMARY_TARGET,highrr,auto,1.5,bitdepth,10,cm,hdr" >/dev/null || exit $EXIT_HYPRCTL_FAILED
    hyprctl keyword monitor "$SECONDARY_TARGET,preferred,auto-left,1.5" >/dev/null || exit $EXIT_HYPRCTL_FAILED

    echo "Switched to dual monitors"
else
    # Neither appears enabled (fallback) -> enable both
    hyprctl keyword monitor "$PRIMARY_TARGET,highrr,auto,1.5,bitdepth,10,cm,hdr" >/dev/null || exit $EXIT_HYPRCTL_FAILED
    hyprctl keyword monitor "$SECONDARY_TARGET,preferred,auto-left,1.5" >/dev/null || exit $EXIT_HYPRCTL_FAILED
    
    echo "Enabled both monitors"
fi