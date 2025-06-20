#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
BIN="$SCRIPT_DIR/../cpu_project_2"

PASS_COUNT=0
FAIL_COUNT=0
TEST_COUNT=0

run_test() {
  TEST_NAME=$1
  COMMANDS=$2
  EXPECTED=$3

  TEST_COUNT=$((TEST_COUNT + 1))
  echo "--- Running test: $TEST_NAME ---"

  output=$("$BIN" <<EOS 2>&1
${COMMANDS}
EOS
)

  if echo "$output" | grep -q "$EXPECTED"; then
    echo "PASS"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "FAIL"
    echo "====DEBUG INFO====="
    echo "$output"
    echo "==================="
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
  echo
}

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
echo "Test Summary"
echo "===================="
echo "TOTAL: $TEST_COUNT, PASS: $PASS_COUNT, FAIL: $FAIL_COUNT"
echo

if [ "$FAIL_COUNT" -ne 0 ]; then
  exit 1
fi

exit 0
