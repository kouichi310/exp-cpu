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
echo "===================="
echo "Test Summary"
echo "===================="
echo "TOTAL: $TEST_COUNT, PASS: $PASS_COUNT, FAIL: $FAIL_COUNT"
echo

if [ "$FAIL_COUNT" -ne 0 ]; then
  exit 1
fi

exit 0
