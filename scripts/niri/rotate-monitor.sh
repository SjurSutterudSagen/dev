#!/bin/bash

# Define monitor description to match against niri output
PRIMARY_TARGET="ASUSTek COMPUTER INC PG32UCDM S6LMQS020784"
#PRIMARY_TARGET="GIGA-BYTE TECHNOLOGY CO., LTD. Gigabyte M32U 0x01010101"

# Exit codes
EXIT_MISSING_DEPS=2
EXIT_INVALID_ARGS=3
EXIT_NIRI_FAILED=4

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	echo "Usage: $0"
	echo "Toggles the primary monitor between landscape and portrait (90°)."
	echo
	echo "Requires niri to be installed and available in PATH."

	exit 0
fi

if ! command -v niri >/dev/null 2>&1; then
	echo "Error: Missing dependency. Requires niri." >&2

	exit $EXIT_MISSING_DEPS
fi

if [ -n "$1" ]; then
	echo "Error: This script takes no arguments. Use --help for usage." >&2

	exit $EXIT_INVALID_ARGS
fi

MONITORS_OUTPUT="$(niri msg outputs)" || exit $EXIT_NIRI_FAILED

CURRENT_TRANSFORM="$(
  printf '%s\n' "$MONITORS_OUTPUT" |
  awk -v desc="$PRIMARY_TARGET" '
    /^Output / {
      current = $0
      in_block = (index(current, desc) > 0)
    }
    in_block && /^[[:space:]]*Transform:/ {
      print $2
      exit
    }
  '
)"

if [ -z "$CURRENT_TRANSFORM" ]; then
	echo "Error: Primary monitor not found. Ensure it is connected or enabled before rotating." >&2

	exit $EXIT_NIRI_FAILED
fi

if [ "$CURRENT_TRANSFORM" = "normal" ]; then
	niri msg output "$PRIMARY_TARGET" transform 90 >/dev/null || exit $EXIT_NIRI_FAILED
	
	echo "Set primary monitor to landscape orientation"
else
	niri msg output "$PRIMARY_TARGET" transform normal >/dev/null || exit $EXIT_NIRI_FAILED

	echo "Set primary monitor to portrait orientation"
fi
