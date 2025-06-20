#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


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

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
