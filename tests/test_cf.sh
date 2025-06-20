#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# RCF clears carry flag
run_test "RCF" "
w 0 0x20
s pc 0
s cf 1
i
d
q
" "cf=0"

# SCF sets carry flag
run_test "SCF" "
w 0 0x28
s pc 0
s cf 0
i
d
q
" "cf=1"

# RCF should not modify VF, NF, ZF
run_test "RCF other flags" "
w 0 0x20
s pc 0
s cf 1
s vf 1
s nf 1
s zf 1
i
d
q
" "cf=0.*vf=1.*nf=1.*zf=1"

# SCF should not modify VF, NF, ZF
run_test "SCF other flags" "
w 0 0x28
s pc 0
s cf 0
s vf 1
s nf 1
s zf 1
i
d
q
" "cf=1.*vf=1.*nf=1.*zf=1"

# PC increment check for RCF
run_test "PC inc RCF" "
w 0 0x20
s pc 0
i
q
" "CPU0,PC=0x1>"

# PC increment check for SCF
run_test "PC inc SCF" "
w 0 0x28
s pc 0
i
q
" "CPU0,PC=0x1>"

# --- Test summary ---
echo "===================="

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
