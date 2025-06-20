#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# --- Sample program test ---
run_test "ACC times IX loop" "
w 0 0x75
w 1 0x03
w 2 0xc0
w 3 0xb5
w 4 0x03
w 5 0xaa
w 6 0x01
w 7 0x31
w 8 0x03
w 9 0x0c
s pc 0
s acc 0x05
s ix 0x04
c
d
q
" "acc=0x14.*ix=0x00"

# --- Test summary ---

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
