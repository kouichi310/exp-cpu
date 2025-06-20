#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# --- Rotate instruction tests ---
# RRA ACC
run_test "RRA ACC" "
w 0 0x44
s pc 0
s acc 0x95
s cf 1
i
d
q
" "acc=0xca.*cf=1.*vf=0.*nf=1.*zf=0"

# RLA ACC
run_test "RLA ACC" "
w 0 0x45
s pc 0
s acc 0x12
s cf 1
i
d
q
" "acc=0x25.*cf=0.*vf=0.*nf=0.*zf=0"

# RRL ACC
run_test "RRL ACC" "
w 0 0x46
s pc 0
s acc 0x81
i
d
q
" "acc=0xc0.*cf=1.*vf=0.*nf=1.*zf=0"

# RLL ACC
run_test "RLL ACC" "
w 0 0x47
s pc 0
s acc 0x81
i
d
q
" "acc=0x03.*cf=1.*vf=0.*nf=0.*zf=0"

# RRA ACC cf=0
run_test "RRA ACC cf=0" "
w 0 0x44
s pc 0
s acc 0x80
s cf 0
i
d
q
" "acc=0x40.*cf=0.*vf=0.*nf=0.*zf=0"

# RLA ACC cf=0
run_test "RLA ACC cf=0" "
w 0 0x45
s pc 0
s acc 0x01
s cf 0
i
d
q
" "acc=0x02.*cf=0.*vf=0.*nf=0.*zf=0"

# RRL ACC cfout=0
run_test "RRL ACC cfout=0" "
w 0 0x46
s pc 0
s acc 0x02
i
d
q
" "acc=0x01.*cf=0.*vf=0.*nf=0.*zf=0"

# RLL ACC cfout=0
run_test "RLL ACC cfout=0" "
w 0 0x47
s pc 0
s acc 0x40
i
d
q
" "acc=0x80.*cf=0.*vf=0.*nf=1.*zf=0"

# RRA ACC zero result
run_test "RRA ACC ZF" "
w 0 0x44
s pc 0
s acc 0x00
s cf 0
i
d
q
" "acc=0x00.*cf=0.*vf=0.*nf=0.*zf=1"

# RRA IX
run_test "RRA IX" "
w 0 0x4c
s pc 0
s ix 0x95
s cf 1
i
d
q
" "ix=0xca.*cf=1.*vf=0.*nf=1.*zf=0"

# RLA IX
run_test "RLA IX" "
w 0 0x4d
s pc 0
s ix 0x12
s cf 1
i
d
q
" "ix=0x25.*cf=0.*vf=0.*nf=0.*zf=0"

# RRL IX
run_test "RRL IX" "
w 0 0x4e
s pc 0
s ix 0x81
i
d
q
" "ix=0xc0.*cf=1.*vf=0.*nf=1.*zf=0"

# RLL IX
run_test "RLL IX" "
w 0 0x4f
s pc 0
s ix 0x81
i
d
q
" "ix=0x03.*cf=1.*vf=0.*nf=0.*zf=0"

# PC increment check
run_test "PC inc RRA" "
w 0 0x44
s pc 0
i
q
" "CPU0,PC=0x1>"

# --- Test summary ---
echo "===================="

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
