#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"

# Build the project
make clean >/dev/null
make >/dev/null

TOTAL=0
PASS=0
FAIL=0
FAIL_MESSAGES=""

for test_script in "$SCRIPT_DIR"/test_*.sh; do
  TOTAL=$((TOTAL + 1))
  TEST_NAME=$(basename "$test_script")
  OUTPUT_FILE=$(mktemp)

  if sh "$test_script" >"$OUTPUT_FILE" 2>&1; then
    printf "."
    PASS=$((PASS + 1))
  else
    printf "F"
    FAIL=$((FAIL + 1))
    FAIL_MESSAGES="$FAIL_MESSAGES\n[${TEST_NAME}]\n$(cat "$OUTPUT_FILE")"
  fi

  rm -f "$OUTPUT_FILE"
done

printf "\n"

if [ "$FAIL" -ne 0 ]; then
  printf "%b\n" "$FAIL_MESSAGES"
fi

echo "===================="
echo "Test Summary"
echo "===================="
echo "TOTAL: $TOTAL, PASS: $PASS, FAIL: $FAIL"

if [ "$FAIL" -ne 0 ]; then
  exit 1
fi

exit 0
