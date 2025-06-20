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

# --- Shift instruction tests ---
# SRA ACC
run_test "SRA ACC" "
w 0 0x40
s pc 0
s acc 0x95
i
d
q
" "acc=0xca.*cf=1.*vf=0.*nf=1.*zf=0"

# SLA ACC
run_test "SLA ACC" "
w 0 0x41
s pc 0
s acc 0x40
i
d
q
" "acc=0x80.*cf=0.*vf=1.*nf=1.*zf=0"

# SRL ACC
run_test "SRL ACC" "
w 0 0x42
s pc 0
s acc 0x01
i
d
q
" "acc=0x00.*cf=1.*vf=0.*nf=0.*zf=1"

# SLL ACC
run_test "SLL ACC" "
w 0 0x43
s pc 0
s acc 0x80
i
d
q
" "acc=0x00.*cf=1.*vf=1.*nf=0.*zf=1"

# SRA ACC pos
run_test "SRA ACC pos" "
w 0 0x40
s pc 0
s acc 0x40
i
d
q
" "acc=0x20.*cf=0.*vf=0.*nf=0.*zf=0"

# SLL ACC VF0
run_test "SLL ACC VF0" "
w 0 0x43
s pc 0
s acc 0x20
i
d
q
" "acc=0x40.*cf=0.*vf=0.*nf=0.*zf=0"

# SRA IX
run_test "SRA IX" "
w 0 0x48
s pc 0
s ix 0x95
i
d
q
" "ix=0xca.*cf=1.*vf=0.*nf=1.*zf=0"

# SLA IX
run_test "SLA IX" "
w 0 0x49
s pc 0
s ix 0x40
i
d
q
" "ix=0x80.*cf=0.*vf=1.*nf=1.*zf=0"

# SRL IX
run_test "SRL IX" "
w 0 0x4a
s pc 0
s ix 0x01
i
d
q
" "ix=0x00.*cf=1.*vf=0.*nf=0.*zf=1"

# SLL IX
run_test "SLL IX" "
w 0 0x4b
s pc 0
s ix 0x80
i
d
q
" "ix=0x00.*cf=1.*vf=1.*nf=0.*zf=1"

# PC increment check
run_test "PC inc SRA" "
w 0 0x40
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
