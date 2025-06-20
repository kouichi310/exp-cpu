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

# RCF clears carry flag
run_test "RCF" "
w 0 0x20
s pc 0
s cf 1
i
d
q
" "cf=0"

# SCF sets carry flag
run_test "SCF" "
w 0 0x28
s pc 0
s cf 0
i
d
q
" "cf=1"

# RCF should not modify VF, NF, ZF
run_test "RCF other flags" "
w 0 0x20
s pc 0
s cf 1
s vf 1
s nf 1
s zf 1
i
d
q
" "cf=0.*vf=1.*nf=1.*zf=1"

# SCF should not modify VF, NF, ZF
run_test "SCF other flags" "
w 0 0x28
s pc 0
s cf 0
s vf 1
s nf 1
s zf 1
i
d
q
" "cf=1.*vf=1.*nf=1.*zf=1"

# PC increment check for RCF
run_test "PC inc RCF" "
w 0 0x20
s pc 0
i
q
" "CPU0,PC=0x1>"

# PC increment check for SCF
run_test "PC inc SCF" "
w 0 0x28
s pc 0
i
q
" "CPU0,PC=0x1>"

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
