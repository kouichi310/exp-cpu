#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# --- OR命令のテストケース ---
# 0. レジスタ指定: OR ACC, ACC (Opcode: 0xD0)
run_test "OR ACC, ACC" "
w 0 0xd0
s pc 0
s acc 0xf0
i
d
q
" "acc=0xf0.*nf=1.*zf=0"

# 1. 演算結果が0の場合 ZFが1になる
run_test "OR zero sets ZF" "
w 0 0xd0
s pc 0
s acc 0x00
i
d
q
" "acc=0x0.*zf=1"

# 2. レジスタ指定: OR ACC, IX (Opcode: 0xD1)
run_test "OR ACC, IX" "
w 0 0xd1
s pc 0
s acc 0xf0
s ix 0x0f
i
d
q
" "acc=0xff.*nf=1.*zf=0"

# 3. 即値: OR ACC, d (Opcode: 0xD2)
run_test "OR ACC, d" "
w 0 0xd2
w 1 0x0f
s pc 0
s acc 0xf0
i
d
q
" "acc=0xff"

# 4. 絶対アドレス（プログラム領域）: OR ACC, [d] (Opcode: 0xD4)
run_test "OR ACC, [d]" "
w 0 0xd4
w 1 0x80
w 0x80 0x0f
s pc 0
s acc 0xf0
i
d
q
" "acc=0xff"

# 5. 絶対アドレス（データ領域）: OR ACC, (d) (Opcode: 0xD5)
run_test "OR ACC, (d)" "
w 0 0xd5
w 1 0x88
w 0x188 0x0f
s pc 0
s acc 0xf0
i
d
q
" "acc=0xff"

# 6. IX修飾（プログラム領域）: OR ACC, [IX+d] (Opcode: 0xD6)
run_test "OR ACC, [IX+d]" "
w 0 0xd6
w 1 0x10
w 0x90 0x01
s pc 0
s acc 0x80
s ix 0x80
i
d
q
" "acc=0x81"

# 7. IX修飾（データ領域）: OR ACC, (IX+d) (Opcode: 0xD7)
run_test "OR ACC, (IX+d)" "
w 0 0xd7
w 1 0x10
w 0x190 0x01
s pc 0
s acc 0x80
s ix 0x80
i
d
q
" "acc=0x81"

# 8. レジスタ指定: OR IX, ACC (Opcode: 0xD8)
run_test "OR IX, ACC" "
w 0 0xd8
s pc 0
s ix 0xf0
s acc 0x0f
i
d
q
" "ix=0xff"

# 9. レジスタ指定: OR IX, IX (Opcode: 0xD9)
run_test "OR IX, IX" "
w 0 0xd9
s pc 0
s ix 0xf0
i
d
q
" "ix=0xf0.*nf=1.*zf=0"

# 10. 即値: OR IX, d (Opcode: 0xDA)
run_test "OR IX, d" "
w 0 0xda
w 1 0x0f
s pc 0
s ix 0xf0
i
d
q
" "ix=0xff"

# 11. 絶対アドレス（プログラム領域）: OR IX, [d] (Opcode: 0xDC)
run_test "OR IX, [d]" "
w 0 0xdc
w 1 0x20
w 0x20 0x0f
s pc 0
s ix 0xf0
i
d
q
" "ix=0xff"

# 12. 絶対アドレス（データ領域）: OR IX, (d) (Opcode: 0xDD)
run_test "OR IX, (d)" "
w 0 0xdd
w 1 0x88
w 0x188 0x0f
s pc 0
s ix 0xf0
i
d
q
" "ix=0xff"

# 13. IX修飾（プログラム領域）: OR IX, [IX+d] (Opcode: 0xDE)
run_test "OR IX, [IX+d]" "
w 0 0xde
w 1 0x10
w 0x90 0x01
s pc 0
s ix 0x80
i
d
q
" "ix=0x81"

# 14. IX修飾（データ領域）: OR IX, (IX+d) (Opcode: 0xDF)
run_test "OR IX, (IX+d)" "
w 0 0xdf
w 1 0x10
w 0x190 0x01
s pc 0
s ix 0x80
i
d
q
" "ix=0x81"

# 15. VFが0にリセットされCFは不変
run_test "OR clears VF" "
w 0 0xd0
s pc 0
s acc 0xf0
s cf 1
s vf 1
w 1 0x0f
# using immediate to ensure result not zero
w 0 0xd2
w 1 0x0f
s pc 0
i
d
q
" "cf=1.*vf=0"

# 16. 1語命令: OR ACC, ACC で PC が +1
run_test "PC inc (1-byte) OR" "
w 0 0xd0
s pc 0
i
d
q
" "CPU0,PC=0x1>"

# 17. 2語命令: OR ACC, d で PC が +2
run_test "PC inc (2-byte) OR" "
w 0 0xd2
w 1 0x00
s pc 0
i
d
q
" "CPU0,PC=0x2>"

# --- テストサマリ ---

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
