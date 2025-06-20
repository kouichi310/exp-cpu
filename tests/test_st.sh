#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# --- ST命令のテストケース ---
# 0. レジスタ指定: ST ACC, ACC (Opcode: 0x70)
run_test "ST ACC, ACC" "
w 0 0x70
s pc 0
s acc 0x11
i
d
q
" "acc=0x11"

# 1. レジスタ指定: ST ACC, IX (Opcode: 0x71)
run_test "ST ACC, IX" "
w 0 0x71
s pc 0
s acc 0x22
s ix 0
i
d
q
" "ix=0x22"

# 2. レジスタ指定: ST IX, ACC (Opcode: 0x78)
run_test "ST IX, ACC" "
w 0 0x78
s pc 0
s ix 0x33
s acc 0
i
d
q
" "acc=0x33"

# 3. 絶対アドレス（プログラム領域）: ST ACC, [d] (Opcode: 0x74)
run_test "ST ACC, [d]" "
w 0 0x74
w 1 0x20
s pc 0
s acc 0x44
i
m 0x20
q
" "| 020:  44"

# 4. 絶対アドレス（データ領域）: ST ACC, (d) (Opcode: 0x75)
run_test "ST ACC, (d)" "
w 0 0x75
w 1 0x88
s pc 0
s acc 0x55
i
m 0x188
q
" "| 188:  55"

# 5. IX修飾（プログラム領域）: ST ACC, [IX+d] (Opcode: 0x76)
run_test "ST ACC, [IX+d]" "
w 0 0x76
w 1 0x10
s pc 0
s acc 0x66
s ix 0x80
i
m 0x90
q
" "| 090:  66"

# 6. IX修飾（データ領域）: ST ACC, (IX+d) (Opcode: 0x77)
run_test "ST ACC, (IX+d)" "
w 0 0x77
w 1 0x10
s pc 0
s acc 0x77
s ix 0x80
i
m 0x190
q
" "| 190:  77"

# 7. 1語命令: ST ACC, IX (Opcode 0x71) で PC が +1
run_test "PC inc (1-byte) ST ACC, IX" "
w 0 0x71
s pc 0
s acc 0x88
i
d
q
" "CPU0,PC=0x1>"

# 8. 2語命令: ST ACC, [d] (Opcode 0x74) で PC が +2
run_test "PC inc (2-byte) ST ACC, [d]" "
w 0 0x74
w 1 0x20
s pc 0
s acc 0x99
i
d
q
" "CPU0,PC=0x2>"

# --- テストサマリ ---

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
