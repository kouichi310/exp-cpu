#!/bin/sh
BIN="$(dirname "$0")/../cpu_project_2"
PASS_COUNT=0
FAIL_COUNT=0
TEST_COUNT=0

run_test() {
  TEST_NAME=$1
  COMMANDS=$2
  EXPECTED=$3

  TEST_COUNT=$((TEST_COUNT + 1))
  echo "--- Running test: $TEST_NAME ---"

  processed=$(printf "%s\n" "$COMMANDS" | sed '$s/^q$/j\nq/')
  output=$("$BIN" <<EOS 2>&1
${processed}
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

print_summary() {
  echo "===================="
  echo "Test Summary"
  echo "===================="
  echo "TOTAL: $TEST_COUNT, PASS: $PASS_COUNT, FAIL: $FAIL_COUNT"
  echo
}
