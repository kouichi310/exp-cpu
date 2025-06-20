#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# BA always taken
run_test "BA" "
w 0 0x30
w 1 0x05
s pc 0
i
q
" "CPU0,PC=0x5>"

# BZ taken and not taken
run_test "BZ taken" "
w 0 0x39
w 1 0x05
s pc 0
s zf 1
i
q
" "CPU0,PC=0x5>"

run_test "BZ not taken" "
w 0 0x39
w 1 0x05
s pc 0
s zf 0
i
q
" "CPU0,PC=0x2>"

# BZP
run_test "BZP taken" "
w 0 0x32
w 1 0x05
s pc 0
s nf 0
i
q
" "CPU0,PC=0x5>"

run_test "BZP not taken" "
w 0 0x32
w 1 0x05
s pc 0
s nf 1
i
q
" "CPU0,PC=0x2>"

# BN
run_test "BN taken" "
w 0 0x3a
w 1 0x05
s pc 0
s nf 1
i
q
" "CPU0,PC=0x5>"

run_test "BN not taken" "
w 0 0x3a
w 1 0x05
s pc 0
s nf 0
i
q
" "CPU0,PC=0x2>"

# BP
run_test "BP taken" "
w 0 0x33
w 1 0x05
s pc 0
s nf 0
s zf 0
i
q
" "CPU0,PC=0x5>"

run_test "BP not taken" "
w 0 0x33
w 1 0x05
s pc 0
s nf 1
s zf 0
i
q
" "CPU0,PC=0x2>"

# BZN
run_test "BZN taken" "
w 0 0x3b
w 1 0x05
s pc 0
s nf 1
s zf 0
i
q
" "CPU0,PC=0x5>"

run_test "BZN not taken" "
w 0 0x3b
w 1 0x05
s pc 0
s nf 0
s zf 0
i
q
" "CPU0,PC=0x2>"

# BNI
run_test "BNI taken" "
w 0 0x34
w 1 0x05
s pc 0
s if 0
i
q
" "CPU0,PC=0x5>"

run_test "BNI not taken" "
w 0 0x34
w 1 0x05
s pc 0
s if 1
i
q
" "CPU0,PC=0x2>"

# BNO
run_test "BNO taken" "
w 0 0x3c
w 1 0x05
s pc 0
s of 1
i
q
" "CPU0,PC=0x5>"

run_test "BNO not taken" "
w 0 0x3c
w 1 0x05
s pc 0
s of 0
i
q
" "CPU0,PC=0x2>"

# BNC
run_test "BNC taken" "
w 0 0x35
w 1 0x05
s pc 0
s cf 0
i
q
" "CPU0,PC=0x5>"

run_test "BNC not taken" "
w 0 0x35
w 1 0x05
s pc 0
s cf 1
i
q
" "CPU0,PC=0x2>"

# BC
run_test "BC taken" "
w 0 0x3d
w 1 0x05
s pc 0
s cf 1
i
q
" "CPU0,PC=0x5>"

run_test "BC not taken" "
w 0 0x3d
w 1 0x05
s pc 0
s cf 0
i
q
" "CPU0,PC=0x2>"

# BGE
run_test "BGE taken" "
w 0 0x36
w 1 0x05
s pc 0
s vf 0
s nf 0
i
q
" "CPU0,PC=0x5>"

run_test "BGE not taken" "
w 0 0x36
w 1 0x05
s pc 0
s vf 1
s nf 0
i
q
" "CPU0,PC=0x2>"

# BLT
run_test "BLT taken" "
w 0 0x3e
w 1 0x05
s pc 0
s vf 1
s nf 0
i
q
" "CPU0,PC=0x5>"

run_test "BLT not taken" "
w 0 0x3e
w 1 0x05
s pc 0
s vf 0
s nf 0
i
q
" "CPU0,PC=0x2>"

# BGT
run_test "BGT taken" "
w 0 0x37
w 1 0x05
s pc 0
s vf 0
s nf 0
s zf 0
i
q
" "CPU0,PC=0x5>"

run_test "BGT not taken" "
w 0 0x37
w 1 0x05
s pc 0
s vf 0
s nf 1
s zf 0
i
q
" "CPU0,PC=0x2>"

# BLE
run_test "BLE taken" "
w 0 0x3f
w 1 0x05
s pc 0
s vf 0
s nf 1
s zf 0
i
q
" "CPU0,PC=0x5>"

run_test "BLE not taken" "
w 0 0x3f
w 1 0x05
s pc 0
s vf 0
s nf 0
s zf 0
i
q
" "CPU0,PC=0x2>"

# BVF
run_test "BVF taken" "
w 0 0x38
w 1 0x05
s pc 0
s vf 1
i
q
" "CPU0,PC=0x5>"

run_test "BVF not taken" "
w 0 0x38
w 1 0x05
s pc 0
s vf 0
i
q
" "CPU0,PC=0x2>"

# --- Test summary ---
echo "===================="

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
