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

# JAL should store return address in ACC and jump to target without side effects
run_test "JAL basic" "
w 0 0x0a
w 1 0x20
s pc 0
s ix 0xaa
s cf 1
s vf 1
s nf 1
s zf 1
i
d
q
" "CPU0,PC=0x20>.*acc=0x02.*ix=0xaa.*cf=1.*vf=1.*nf=1.*zf=1"

# JR should jump to address in ACC without altering registers or flags
run_test "JR basic" "
w 0 0x0b
s pc 0
s acc 0x30
s ix 0xbb
s cf 1
s vf 1
s nf 1
s zf 1
i
d
q
" "CPU0,PC=0x30>.*acc=0x30.*ix=0xbb.*cf=1.*vf=1.*nf=1.*zf=1"

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
