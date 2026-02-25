#!/bin/bash

# Define monitor descriptions to match against hyprctl output
PRIMARY_DESC="ASUSTek COMPUTER INC PG32UCDM S6LMQS020784"
SECONDARY_DESC="GIGA-BYTE TECHNOLOGY CO. LTD. Gigabyte M32U 0x01010101"

# Exit codes
EXIT_MISSING_DEPS=2
EXIT_INVALID_ARGS=3
EXIT_HYPRCTL_FAILED=4

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	echo "Usage: $0 [1|2]"
	echo "Applies a specific monitor configuration."
	echo
	echo "No argument: Enable both monitors"
	echo "1: Primary monitor only"
	echo "2: Secondary monitor only"
	echo
	echo "Requires hyprctl to be installed and available in PATH."
	exit 0
fi

if ! command -v hyprctl >/dev/null 2>&1; then
	echo "Error: Missing dependency. Requires hyprctl." >&2

	exit $EXIT_MISSING_DEPS
fi

MODE="both"

if [ -n "$1" ]; then
	case "$1" in
	1) MODE="primary" ;;
	2) MODE="secondary" ;;
	*)
		echo "Error: Invalid argument '$1'. Use 1, 2, or no argument." >&2

		exit $EXIT_INVALID_ARGS
		;;
	esac
fi

PRIMARY_TARGET="desc:$PRIMARY_DESC"
SECONDARY_TARGET="desc:$SECONDARY_DESC"

if [ "$MODE" = "primary" ]; then
	hyprctl keyword monitor "$PRIMARY_TARGET,highrr,auto,1.5,bitdepth,10,cm,hdr" >/dev/null || exit $EXIT_HYPRCTL_FAILED
	hyprctl keyword monitor "$SECONDARY_TARGET,disabled" >/dev/null || exit $EXIT_HYPRCTL_FAILED

	echo "Switched to primary monitor only"
elif [ "$MODE" = "secondary" ]; then
	hyprctl keyword monitor "$PRIMARY_TARGET,disabled" >/dev/null || exit $EXIT_HYPRCTL_FAILED
	hyprctl keyword monitor "$SECONDARY_TARGET,preferred,auto-left,1.5" >/dev/null || exit $EXIT_HYPRCTL_FAILED

	echo "Switched to secondary monitor only"
else
	hyprctl keyword monitor "$PRIMARY_TARGET,highrr,auto,1.5,bitdepth,10,cm,hdr" >/dev/null || exit $EXIT_HYPRCTL_FAILED
	hyprctl keyword monitor "$SECONDARY_TARGET,preferred,auto-left,1.5" >/dev/null || exit $EXIT_HYPRCTL_FAILED

	echo "Switched to dual monitors"
fi
