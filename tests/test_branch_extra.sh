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
echo "===================="
echo "Test Summary"
echo "===================="
echo "TOTAL: $TEST_COUNT, PASS: $PASS_COUNT, FAIL: $FAIL_COUNT"
echo

if [ "$FAIL_COUNT" -ne 0 ]; then
  exit 1
fi

exit 0
