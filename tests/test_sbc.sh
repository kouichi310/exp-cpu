#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# --- SBC命令のテストケース ---
# 0. レジスタ指定: SBC ACC, ACC (Opcode: 0x80)
run_test "SBC ACC, ACC" "
w 0 0x80
s pc 0
s acc 0x03
s cf 1
i
d
q
" "acc=0xff.*cf=1"

# 1. レジスタ指定: SBC ACC, IX (Opcode: 0x81)
run_test "SBC ACC, IX" "
w 0 0x81
s pc 0
s acc 0x05
s ix 0x02
s cf 1
i
d
q
" "acc=0x02"

# 2. 即値: SBC ACC, d (Opcode: 0x82)
run_test "SBC ACC, d" "
w 0 0x82
w 1 0x01
s pc 0
s acc 0x05
s cf 1
i
d
q
" "acc=0x03"

# 3. 絶対アドレス（プログラム領域）: SBC ACC, [d] (Opcode: 0x84)
run_test "SBC ACC, [d]" "
w 0 0x84
w 1 0x20
w 0x20 0x03
s pc 0
s acc 0x05
s cf 1
i
d
q
" "acc=0x01"

# 4. 絶対アドレス（データ領域）: SBC ACC, (d) (Opcode: 0x85)
run_test "SBC ACC, (d)" "
w 0 0x85
w 1 0x88
w 0x188 0x01
s pc 0
s acc 0x03
s cf 1
i
d
q
" "acc=0x01"

# 5. IX修飾（プログラム領域）: SBC ACC, [IX+d] (Opcode: 0x86)
run_test "SBC ACC, [IX+d]" "
w 0 0x86
w 1 0x10
w 0x90 0x02
s pc 0
s acc 0x05
s ix 0x80
s cf 1
i
d
q
" "acc=0x02"

# 6. IX修飾（データ領域）: SBC ACC, (IX+d) (Opcode: 0x87)
run_test "SBC ACC, (IX+d)" "
w 0 0x87
w 1 0x10
w 0x190 0x01
s pc 0
s acc 0x05
s ix 0x80
s cf 1
i
d
q
" "acc=0x03"

# 7. レジスタ指定: SBC IX, ACC (Opcode: 0x88)
run_test "SBC IX, ACC" "
w 0 0x88
s pc 0
s ix 0x05
s acc 0x02
s cf 1
i
d
q
" "ix=0x02"

# 8. レジスタ指定: SBC IX, IX (Opcode: 0x89)
run_test "SBC IX, IX" "
w 0 0x89
s pc 0
s ix 0x05
s cf 1
i
d
q
" "ix=0xff.*cf=1"

# 9. 即値: SBC IX, d (Opcode: 0x8A)
run_test "SBC IX, d" "
w 0 0x8a
w 1 0x01
s pc 0
s ix 0x05
s cf 1
i
d
q
" "ix=0x03"

# 10. 絶対アドレス（プログラム領域）: SBC IX, [d] (Opcode: 0x8C)
run_test "SBC IX, [d]" "
w 0 0x8c
w 1 0x30
w 0x30 0x03
s pc 0
s ix 0x05
s cf 1
i
d
q
" "ix=0x01"

# 11. 絶対アドレス（データ領域）: SBC IX, (d) (Opcode: 0x8D)
run_test "SBC IX, (d)" "
w 0 0x8d
w 1 0x90
w 0x190 0x02
s pc 0
s ix 0x05
s cf 1
i
d
q
" "ix=0x02"

# 12. IX修飾（プログラム領域）: SBC IX, [IX+d] (Opcode: 0x8E)
run_test "SBC IX, [IX+d]" "
w 0 0x8e
w 1 0x10
w 0x90 0x01
s pc 0
s ix 0x80
s cf 1
i
d
q
" "ix=0x7e"

# 13. IX修飾（データ領域）: SBC IX, (IX+d) (Opcode: 0x8F)
run_test "SBC IX, (IX+d)" "
w 0 0x8f
w 1 0x10
w 0x190 0x02
s pc 0
s ix 0x80
s cf 1
i
d
q
" "ix=0x7d"

# 14. BorrowでCFセット
run_test "SBC borrow" "
w 0 0x82
w 1 0x02
s pc 0
s acc 0x01
s cf 0
i
d
q
" "acc=0xff.*cf=1"

# 15. VFセット例
run_test "SBC VF" "
w 0 0x82
w 1 0x80
s pc 0
s acc 0x7f
s cf 0
i
d
q
" "acc=0xff.*vf=1"

# 16. 結果が0になるとZFが1
run_test "SBC ZF" "
w 0 0x82
w 1 0x01
s pc 0
s acc 0x01
s cf 0
i
d
q
" "acc=0x00.*cf=0.*vf=0.*nf=0.*zf=1"

# 17. 1語命令でPCが+1
run_test "PC inc (1-byte) SBC ACC, ACC" "
w 0 0x80
s pc 0
s cf 0
i
q
" "CPU0,PC=0x1>"

# 18. 2語命令でPCが+2
run_test "PC inc (2-byte) SBC ACC, d" "
w 0 0x82
w 1 0x00
s pc 0
s cf 0
i
q
" "CPU0,PC=0x2>"

# --- テストサマリ ---
echo "===================="

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
