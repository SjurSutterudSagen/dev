#!/bin/bash

# Define monitor descriptions to match against niri output
PRIMARY_TARGET="ASUSTek COMPUTER INC PG32UCDM S6LMQS020784"
SECONDARY_TARGET="GIGA-BYTE TECHNOLOGY CO., LTD. Gigabyte M32U 0x01010101"

# Exit codes
EXIT_MISSING_DEPS=2
EXIT_INVALID_ARGS=3
EXIT_NIRI_FAILED=4

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	echo "Usage: $0 [1|2]"
	echo "Applies a specific monitor configuration."
	echo
	echo "No argument: Enable both monitors"
	echo "1: Primary monitor only"
	echo "2: Secondary monitor only"
	echo
	echo "Requires niri to be installed and available in PATH."

	exit 0
fi

if ! command -v niri >/dev/null 2>&1; then
	echo "Error: Missing dependency. Requires niri." >&2

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

if [ "$MODE" = "primary" ]; then
	niri msg output "$PRIMARY_TARGET" on
	niri msg output "$SECONDARY_TARGET" off

	echo "Switched to primary monitor only"
elif [ "$MODE" = "secondary" ]; then
	niri msg output "$PRIMARY_TARGET" off
	niri msg output "$SECONDARY_TARGET" on

	echo "Switched to secondary monitor only"
else
	niri msg output "$PRIMARY_TARGET" on
	niri msg output "$SECONDARY_TARGET" on

	echo "Switched to dual monitors"
fi
