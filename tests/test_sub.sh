#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# --- SUB命令のテストケース ---
# 0. レジスタ指定: SUB ACC, ACC (Opcode: 0xA0)
run_test "SUB ACC, ACC" "
w 0 0xa0
s pc 0
s acc 0x11
i
d
q
" "acc=0x00.*cf=0.*vf=0.*nf=0.*zf=1"

# 1. レジスタ指定: SUB ACC, IX (Opcode: 0xA1)
run_test "SUB ACC, IX" "
w 0 0xa1
s pc 0
s acc 0x05
s ix 0x02
i
d
q
" "acc=0x03.*cf=0.*vf=0.*nf=0.*zf=0"

# 2. 即値: SUB ACC, d (Opcode: 0xA2)
run_test "SUB ACC, d" "
w 0 0xa2
w 1 0x01
s pc 0
s acc 0x05
i
d
q
" "acc=0x04.*cf=0.*vf=0.*nf=0.*zf=0"

# 3. 絶対アドレス（プログラム領域）: SUB ACC, [d] (Opcode: 0xA4)
run_test "SUB ACC, [d]" "
w 0 0xa4
w 1 0x20
w 0x20 0x03
s pc 0
s acc 0x05
i
d
q
" "acc=0x02.*cf=0.*vf=0.*nf=0.*zf=0"

# 4. 絶対アドレス（データ領域）: SUB ACC, (d) (Opcode: 0xA5)
run_test "SUB ACC, (d)" "
w 0 0xa5
w 1 0x88
w 0x188 0x01
s pc 0
s acc 0x02
i
d
q
" "acc=0x01.*cf=0.*vf=0.*nf=0.*zf=0"

# 5. IX修飾（プログラム領域）: SUB ACC, [IX+d] (Opcode: 0xA6)
run_test "SUB ACC, [IX+d]" "
w 0 0xa6
w 1 0x10
w 0x90 0x02
s pc 0
s acc 0x05
s ix 0x80
i
d
q
" "acc=0x03.*cf=0.*vf=0.*nf=0.*zf=0"

# 6. IX修飾（データ領域）: SUB ACC, (IX+d) (Opcode: 0xA7)
run_test "SUB ACC, (IX+d)" "
w 0 0xa7
w 1 0x10
w 0x190 0x01
s pc 0
s acc 0x05
s ix 0x80
i
d
q
" "acc=0x04.*cf=0.*vf=0.*nf=0.*zf=0"

# 7. レジスタ指定: SUB IX, ACC (Opcode: 0xA8)
run_test "SUB IX, ACC" "
w 0 0xa8
s pc 0
s ix 0x05
s acc 0x03
i
d
q
" "ix=0x02.*cf=0.*vf=0.*nf=0.*zf=0"

# 8. レジスタ指定: SUB IX, IX (Opcode: 0xA9)
run_test "SUB IX, IX" "
w 0 0xa9
s pc 0
s ix 0x05
i
d
q
" "ix=0x00.*cf=0.*vf=0.*nf=0.*zf=1"

# 9. 即値: SUB IX, d (Opcode: 0xAA)
run_test "SUB IX, d" "
w 0 0xaa
w 1 0x01
s pc 0
s ix 0x05
i
d
q
" "ix=0x04.*cf=0.*vf=0.*nf=0.*zf=0"

# 10. 絶対アドレス（プログラム領域）: SUB IX, [d] (Opcode: 0xAC)
run_test "SUB IX, [d]" "
w 0 0xac
w 1 0x30
w 0x30 0x03
s pc 0
s ix 0x05
i
d
q
" "ix=0x02.*cf=0.*vf=0.*nf=0.*zf=0"

# 11. 絶対アドレス（データ領域）: SUB IX, (d) (Opcode: 0xAD)
run_test "SUB IX, (d)" "
w 0 0xad
w 1 0x90
w 0x190 0x02
s pc 0
s ix 0x05
i
d
q
" "ix=0x03.*cf=0.*vf=0.*nf=0.*zf=0"

# 12. IX修飾（プログラム領域）: SUB IX, [IX+d] (Opcode: 0xAE)
run_test "SUB IX, [IX+d]" "
w 0 0xae
w 1 0x10
w 0x90 0x01
s pc 0
s ix 0x80
i
d
q
" "ix=0x7f.*cf=0.*vf=1.*nf=0.*zf=0"

# 13. IX修飾（データ領域）: SUB IX, (IX+d) (Opcode: 0xAF)
run_test "SUB IX, (IX+d)" "
w 0 0xaf
w 1 0x10
w 0x190 0x02
s pc 0
s ix 0x80
i
d
q
" "ix=0x7e.*cf=0.*vf=1.*nf=0.*zf=0"

# 14. Borrow sets CF (0x01 - 0x02)
run_test "SUB borrow sets CF" "
w 0 0xa2
w 1 0x02
s pc 0
s acc 0x01
i
d
q
" "acc=0xff.*cf=1.*vf=0.*nf=1.*zf=0"

# 15. 1語命令でPCが+1
run_test "PC inc (1-byte) SUB ACC, ACC" "
w 0 0xa0
s pc 0
i
d
q
" "CPU0,PC=0x1>"

# 16. 2語命令でPCが+2
run_test "PC inc (2-byte) SUB ACC, d" "
w 0 0xa2
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
