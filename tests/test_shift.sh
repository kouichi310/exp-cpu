#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


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

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
