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

# OUT instruction transfers ACC to OBUF
run_test "OUT" "
w 0 0x10
s pc 0
s acc 0xab
i
d
q
" "obuf=1:0xab"

# IN instruction transfers IBUF to ACC and clears flag
run_test "IN" "
w 0 0x18
s pc 0
s ibuf 0x55
s if 1
s acc 0x00
i
d
q
" "acc=0x55"

# IN clears input flag
run_test "IN flag clear" "
w 0 0x18
s pc 0
s ibuf 0x55
s if 1
s acc 0x00
i
d
q
" "ibuf=0"

# OUT should not modify arithmetic flags
run_test "OUT flags" "
w 0 0x10
s pc 0
s acc 0x12
s cf 1
s vf 1
s nf 1
s zf 1
i
d
q
" "cf=1.*vf=1.*nf=1.*zf=1"

# IN should clear flag and keep arithmetic flags
run_test "IN flags" "
w 0 0x18
s pc 0
s ibuf 0x34
s if 1
s acc 0x00
s cf 1
s vf 1
s nf 1
s zf 1
i
d
q
" "acc=0x34.*cf=1.*vf=1.*nf=1.*zf=1"

# PC increment check for OUT
run_test "PC inc OUT" "
w 0 0x10
s pc 0
i
q
" "CPU0,PC=0x1>"

# PC increment check for IN
run_test "PC inc IN" "
w 0 0x18
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
