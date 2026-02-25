#!/bin/bash

# Define monitor description to match against hyprctl output
PRIMARY_DESC="ASUSTek COMPUTER INC PG32UCDM S6LMQS020784"
PRIMARY_TARGET="desc:$PRIMARY_DESC"

# Exit codes
EXIT_MISSING_DEPS=2
EXIT_INVALID_ARGS=3
EXIT_HYPRCTL_FAILED=4

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	echo "Usage: $0"
	echo "Toggles the primary monitor between landscape and portrait (90°)."
	echo
	echo "Requires hyprctl to be installed and available in PATH."

	exit 0
fi

if ! command -v hyprctl >/dev/null 2>&1; then
	echo "Error: Missing dependency. Requires hyprctl." >&2

	exit $EXIT_MISSING_DEPS
fi

if [ -n "$1" ]; then
	echo "Error: This script takes no arguments. Use --help for usage." >&2

	exit $EXIT_INVALID_ARGS
fi

MONITORS_OUTPUT="$(hyprctl monitors)" || exit $EXIT_HYPRCTL_FAILED

CURRENT_TRANSFORM="$(printf '%s\n' "$MONITORS_OUTPUT" | awk -v desc="$PRIMARY_DESC" '
	$1 == "description:" {
		current_desc = substr($0, index($0, $2))
	}
	$1 == "transform:" && current_desc == desc {
		print $2
		exit
	}
')"

if [ -z "$CURRENT_TRANSFORM" ]; then
	echo "Error: Primary monitor not found. Ensure it is connected or enabled before rotating." >&2

	exit $EXIT_HYPRCTL_FAILED
fi

if [ "$CURRENT_TRANSFORM" = "1" ]; then
	hyprctl keyword monitor "$PRIMARY_TARGET,highrr,auto,1.5,bitdepth,10,cm,hdr" >/dev/null || exit $EXIT_HYPRCTL_FAILED

	echo "Set primary monitor to landscape orientation"
else
	hyprctl keyword monitor "$PRIMARY_TARGET,highrr,auto,1.5,bitdepth,10,cm,hdr,transform,1" >/dev/null || exit $EXIT_HYPRCTL_FAILED

	echo "Set primary monitor to portrait orientation"
fi
