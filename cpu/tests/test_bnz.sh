#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# BNZ taken when ZF=0
run_test "BNZ taken" "
w 0 0x31
w 1 0x05
s pc 0
s zf 0
i
q
" "CPU0,PC=0x5>"

# BNZ not taken when ZF=1
run_test "BNZ not taken" "
w 0 0x31
w 1 0x08
s pc 0
s zf 1
i
q
" "CPU0,PC=0x2>"

# --- Test summary ---

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
