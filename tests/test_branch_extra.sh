#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# Additional branch tests for complex flag combinations

# BP should branch when NF=1 and ZF=1
run_test "BP nf=1 zf=1" "
w 0 0x33
w 1 0x05
s pc 0
s nf 1
s zf 1
i
q
" "CPU0,PC=0x5>"

# BZN should branch when ZF=1 and NF=0
run_test "BZN zf=1" "
w 0 0x3b
w 1 0x05
s pc 0
s nf 0
s zf 1
i
q
" "CPU0,PC=0x5>"

# BGT should branch when VF=1, NF=1 and ZF=0
run_test "BGT vf=1 nf=1" "
w 0 0x37
w 1 0x05
s pc 0
s vf 1
s nf 1
s zf 0
i
q
" "CPU0,PC=0x5>"

# BLE should branch when VF=1 and NF=0
run_test "BLE vf=1 nf=0" "
w 0 0x3f
w 1 0x05
s pc 0
s vf 1
s nf 0
s zf 0
i
q
" "CPU0,PC=0x5>"

# BLE should branch when ZF=1 regardless of VF/NF
run_test "BLE zf=1" "
w 0 0x3f
w 1 0x05
s pc 0
s vf 0
s nf 0
s zf 1
i
q
" "CPU0,PC=0x5>"

# --- Test summary ---

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
