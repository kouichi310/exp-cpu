#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# --- NOP命令のテストケース ---
# 0. レジスタ・フラグが変化しない
run_test "NOP does nothing" "
w 0 0x00
s pc 0
s acc 0x12
s ix 0x34
s cf 1
s vf 1
s nf 1
s zf 1
i
d
q
" "acc=0x12.*ix=0x34.*cf=1.*vf=1.*nf=1.*zf=1"

# 1. PCが+1される
run_test "PC inc NOP" "
w 0 0x00
s pc 0
i
d
q
" "CPU0,PC=0x1>"

# --- テストサマリ ---
echo "===================="

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
