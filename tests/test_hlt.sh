#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"



# HLT opcodes range from 0x0C to 0x0F
for code in 0x0c 0x0d 0x0e 0x0f; do
  run_test "HLT opcode $code" "
w 0 $code
s pc 0
i
q
" "Program Halted."
done

# --- Test summary ---
echo "===================="

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
