#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


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

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
