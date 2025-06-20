#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# --- LD命令のテストケース ---
# 0. レジスタ指定: LD ACC, ACC (Opcode: 0x60)
run_test "LD ACC, ACC" "
w 0 0x60
s pc 0
s acc 0xA0
s nf 0
i
d
q
" "acc=0xa0.*nf=0"

# 1. レジスタ指定: LD ACC, IX (Opcode: 0x61)
run_test "LD ACC, IX" "
w 0 0x61
s pc 0
s acc 0
s ix 0xCD
i
d
q
" "acc=0xcd"

# 2. 即値: LD ACC, d (Opcode: 0x62)
run_test "LD ACC, d" "
w 0 0x62
w 1 0xDE
s pc 0
s acc 0
i
d
q
" "acc=0xde"

# 3. 絶対アドレス（プログラム領域）: LD ACC, [d] (Opcode: 0x64)
run_test "LD ACC, [d]" "
w 0 0x64
w 1 0x70
w 0x70 0x55
s pc 0
s acc 0
i
d
q
" "acc=0x55"

# 4. 絶対アドレス（データ領域）: LD ACC, (d) (Opcode: 0x65)
run_test "LD ACC, (d)" "
w 0 0x65
w 1 0x88
w 0x188 0xAB
s pc 0
s acc 0
i
d
q
" "acc=0xab"

# 5. IX修飾（プログラム領域）: LD ACC, [IX+d] (Opcode: 0x66)
run_test "LD ACC, [IX+d]" "
w 0 0x66
w 1 0x30
w 0x90 0x99
s pc 0
s acc 0
s ix 0x60
m 0x90
i
d
q
" "acc=0x99"

# 6. IX修飾（データ領域）: LD ACC, (IX+d) (Opcode: 0x67)
run_test "LD ACC, (IX+d)" "
w 0 0x67
w 1 0x40
w 0x1A0 0xBB
s pc 0
s acc 0
s ix 0x60
m 0x1a0
i
d
q
" "acc=0xbb"

# 7. レジスタ指定: LD IX, IX (Opcode: 0x69)
run_test "LD IX, IX" "
w 0 0x69
s pc 0
s ix 0xB0
s nf 0
i
d
q
" "ix=0xb0.*nf=0"

# 8. レジスタ指定: LD IX, ACC (Opcode: 0x68)
run_test "LD IX, ACC" "
w 0 0x68
s pc 0
s ix 0
s acc 0xDD
i
d
q
" "ix=0xdd"

# 9. 即値: LD IX, d (Opcode: 0x6A)
run_test "LD IX, d" "
w 0 0x6a
w 1 0xEE
s pc 0
s ix 0
i
d
q
" "ix=0xee"

# 10. 絶対アドレス（プログラム領域）: LD IX, [d] (Opcode: 0x6C)
run_test "LD IX, [d]" "
w 0 0x6c
w 1 0x71
w 0x71 0x56
s pc 0
s ix 0
i
d
q
" "ix=0x56"

# 11. 絶対アドレス（データ領域）: LD IX, (d) (Opcode: 0x6D)
run_test "LD IX, (d)" "
w 0 0x6d
w 1 0x89
w 0x189 0xAC
s pc 0
s ix 0
i
d
q
" "ix=0xac"

# 12. IX修飾（プログラム領域）: LD IX, [IX+d] (Opcode: 0x6E)
run_test "LD IX, [IX+d]" "
w 0 0x6e
w 1 0x31
w 0x91 0x9A
s pc 0
s ix 0x60
i
d
q
" "ix=0x9a"

# 13. IX修飾（データ領域）: LD IX, (IX+d) (Opcode: 0x6F)
run_test "LD IX, (IX+d)" "
w 0 0x6f
w 1 0x41
w 0x1A1 0xBC
s pc 0
s ix 0x60
i
d
q
" "ix=0xbc"

# 14. 1語命令: LD ACC, ACC (Opcode 0x60) で PC が +1
run_test "PC inc (1-byte) LD ACC, ACC" "
w 0 0x60
s pc 0
s acc 0x12
i
d
q
" "CPU0,PC=0x1>"

# 15. 2語命令: LD ACC, d (Opcode 0x62) で PC が +2
run_test "PC inc (2-byte) LD ACC, d" "
w 0 0x62
w 1 0x34
s pc 0
i
d
q
" "CPU0,PC=0x2>"

# 16. 1語命令: LD IX, ACC (Opcode 0x68) で IX に値が入り PC が +1
run_test "PC inc (1-byte) LD IX, ACC" "
w 0 0x68
s pc 0
s acc 0x56
s ix  0x00
i
d
q
" "CPU0,PC=0x1>"

# --- テストサマリ ---

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
