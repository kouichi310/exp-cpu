#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"

# Build the project
make clean >/dev/null
make >/dev/null

EXIT_STATUS=0
for test_script in "$SCRIPT_DIR"/test_*.sh; do
  echo "Running $(basename "$test_script")" >&2
  if sh "$test_script"; then
    echo "ALL TEST IS PASS" >&2
  else
    echo "FAIL" >&2
    EXIT_STATUS=1
  fi
  echo >&2
done
exit $EXIT_STATUS
