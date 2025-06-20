#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# --- ADD命令のテストケース ---
# 0. レジスタ指定: ADD ACC, ACC (Opcode: 0xB0)
run_test "ADD ACC, ACC" "
w 0 0xb0
s pc 0
s acc 0x11
i
d
q
" "acc=0x22.*cf=0.*vf=0.*nf=0.*zf=0"

# 1. レジスタ指定: ADD ACC, IX (Opcode: 0xB1)
run_test "ADD ACC, IX" "
w 0 0xb1
s pc 0
s acc 0x01
s ix 0x02
i
d
q
" "acc=0x03.*cf=0.*vf=0.*nf=0.*zf=0"

# 2. 即値: ADD ACC, d (Opcode: 0xB2)
run_test "ADD ACC, d" "
w 0 0xb2
w 1 0x05
s pc 0
s acc 0x03
i
d
q
" "acc=0x08.*cf=0.*vf=0.*nf=0.*zf=0"

# 3. 絶対アドレス（プログラム領域）: ADD ACC, [d] (Opcode: 0xB4)
run_test "ADD ACC, [d]" "
w 0 0xb4
w 1 0x20
w 0x20 0x07
s pc 0
s acc 0x01
i
d
q
" "acc=0x08.*cf=0.*vf=0.*nf=0.*zf=0"

# 4. 絶対アドレス（データ領域）: ADD ACC, (d) (Opcode: 0xB5)
run_test "ADD ACC, (d)" "
w 0 0xb5
w 1 0x88
w 0x188 0x04
s pc 0
s acc 0x01
i
d
q
" "acc=0x05.*cf=0.*vf=0.*nf=0.*zf=0"

# 5. IX修飾（プログラム領域）: ADD ACC, [IX+d] (Opcode: 0xB6)
run_test "ADD ACC, [IX+d]" "
w 0 0xb6
w 1 0x10
w 0x90 0x03
s pc 0
s acc 0x02
s ix 0x80
i
d
q
" "acc=0x05.*cf=0.*vf=0.*nf=0.*zf=0"

# 6. IX修飾（データ領域）: ADD ACC, (IX+d) (Opcode: 0xB7)
run_test "ADD ACC, (IX+d)" "
w 0 0xb7
w 1 0x10
w 0x190 0x06
s pc 0
s acc 0x02
s ix 0x80
i
d
q
" "acc=0x08.*cf=0.*vf=0.*nf=0.*zf=0"

# 7. レジスタ指定: ADD IX, ACC (Opcode: 0xB8)
run_test "ADD IX, ACC" "
w 0 0xb8
s pc 0
s ix 0x01
s acc 0x02
i
d
q
" "ix=0x03.*cf=0.*vf=0.*nf=0.*zf=0"

# 8. レジスタ指定: ADD IX, IX (Opcode: 0xB9)
run_test "ADD IX, IX" "
w 0 0xb9
s pc 0
s ix 0x04
i
d
q
" "ix=0x08.*cf=0.*vf=0.*nf=0.*zf=0"

# 9. 即値: ADD IX, d (Opcode: 0xBA)
run_test "ADD IX, d" "
w 0 0xba
w 1 0x03
s pc 0
s ix 0x02
i
d
q
" "ix=0x05.*cf=0.*vf=0.*nf=0.*zf=0"

# 10. 絶対アドレス（プログラム領域）: ADD IX, [d] (Opcode: 0xBC)
run_test "ADD IX, [d]" "
w 0 0xbc
w 1 0x30
w 0x30 0x03
s pc 0
s ix 0x01
i
d
q
" "ix=0x04.*cf=0.*vf=0.*nf=0.*zf=0"

# 11. 絶対アドレス（データ領域）: ADD IX, (d) (Opcode: 0xBD)
run_test "ADD IX, (d)" "
w 0 0xbd
w 1 0x90
w 0x190 0x02
s pc 0
s ix 0x02
i
d
q
" "ix=0x04.*cf=0.*vf=0.*nf=0.*zf=0"

# 12. IX修飾（プログラム領域）: ADD IX, [IX+d] (Opcode: 0xBE)
run_test "ADD IX, [IX+d]" "
w 0 0xbe
w 1 0x10
w 0x90 0x01
s pc 0
s ix 0x80
i
d
q
" "ix=0x81.*cf=0.*vf=0.*nf=1.*zf=0"

# 13. IX修飾（データ領域）: ADD IX, (IX+d) (Opcode: 0xBF)
run_test "ADD IX, (IX+d)" "
w 0 0xbf
w 1 0x10
w 0x190 0x02
s pc 0
s ix 0x80
i
d
q
" "ix=0x82.*cf=0.*vf=0.*nf=1.*zf=0"

# 14. CF, VF, NF, ZF の更新確認
run_test "ADD flag update" "
w 0 0xb0
s pc 0
s acc 0x80
s ix 0x80
w 1 0x00
s cf 1
i
d
q
" "acc=0x00.*cf=1.*vf=1.*nf=0.*zf=1"

# 15. 1語命令: ADD ACC, ACC で PC が +1
run_test "PC inc (1-byte) ADD ACC, ACC" "
w 0 0xb0
s pc 0
s acc 0x01
i
d
q
" "CPU0,PC=0x1>"

# 16. 2語命令: ADD ACC, d で PC が +2
run_test "PC inc (2-byte) ADD ACC, d" "
w 0 0xb2
w 1 0x01
s pc 0
i
d
q
" "CPU0,PC=0x2>"

# 17. CFのみ事前セット: 0xFF + 0x01
run_test "ADD flags CF preserved" "
w 0 0xb2
w 1 0x01
s pc 0
s acc 0xff
s cf 1
i
d
q
" "acc=0x00.*cf=1.*vf=0.*nf=0.*zf=1"

# 18. NFのみセットされる例
run_test "ADD flags NF" "
w 0 0xb2
w 1 0x80
s pc 0
s acc 0x01
i
d
q
" "acc=0x81.*cf=0.*vf=0.*nf=1.*zf=0"

# 19. VFセット例
run_test "ADD flags VF" "
w 0 0xb2
w 1 0x01
s pc 0
s acc 0x7f
i
d
q
" "acc=0x80.*cf=0.*vf=1.*nf=1.*zf=0"

# 20. 全フラグ立たず
run_test "ADD flags none" "
w 0 0xb2
w 1 0x02
s pc 0
s acc 0x01
i
d
q
" "acc=0x03.*cf=0.*vf=0.*nf=0.*zf=0"

# --- テストサマリ ---
echo "===================="

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
