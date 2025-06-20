#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
. "$SCRIPT_DIR/test_helper.sh"


# --- ADC命令のテストケース ---
# 0. レジスタ指定: ADC ACC, ACC (Opcode: 0x90)
run_test "ADC ACC, ACC" "
w 0 0x90
s pc 0
s acc 0x01
s cf 1
i
d
q
" "acc=0x03.*cf=0"

# 1. レジスタ指定: ADC ACC, IX (Opcode: 0x91)
run_test "ADC ACC, IX" "
w 0 0x91
s pc 0
s acc 0x01
s ix 0x01
s cf 1
i
d
q
" "acc=0x03"

# 2. 即値: ADC ACC, d (Opcode: 0x92)
run_test "ADC ACC, d" "
w 0 0x92
w 1 0x05
s pc 0
s acc 0x03
s cf 1
i
d
q
" "acc=0x09"

# 3. 絶対アドレス（プログラム領域）: ADC ACC, [d] (Opcode: 0x94)
run_test "ADC ACC, [d]" "
w 0 0x94
w 1 0x20
w 0x20 0x07
s pc 0
s acc 0x01
s cf 1
i
d
q
" "acc=0x09"

# 4. 絶対アドレス（データ領域）: ADC ACC, (d) (Opcode: 0x95)
run_test "ADC ACC, (d)" "
w 0 0x95
w 1 0x88
w 0x188 0x04
s pc 0
s acc 0x01
s cf 1
i
d
q
" "acc=0x06"

# 5. IX修飾（プログラム領域）: ADC ACC, [IX+d] (Opcode: 0x96)
run_test "ADC ACC, [IX+d]" "
w 0 0x96
w 1 0x10
w 0x90 0x03
s pc 0
s acc 0x02
s ix 0x80
s cf 1
i
d
q
" "acc=0x06"

# 6. IX修飾（データ領域）: ADC ACC, (IX+d) (Opcode: 0x97)
run_test "ADC ACC, (IX+d)" "
w 0 0x97
w 1 0x10
w 0x190 0x06
s pc 0
s acc 0x02
s ix 0x80
s cf 1
i
d
q
" "acc=0x09"

# 7. レジスタ指定: ADC IX, ACC (Opcode: 0x98)
run_test "ADC IX, ACC" "
w 0 0x98
s pc 0
s ix 0x01
s acc 0x02
s cf 1
i
d
q
" "ix=0x04"

# 8. レジスタ指定: ADC IX, IX (Opcode: 0x99)
run_test "ADC IX, IX" "
w 0 0x99
s pc 0
s ix 0x01
s cf 1
i
d
q
" "ix=0x03"

# 9. 即値: ADC IX, d (Opcode: 0x9A)
run_test "ADC IX, d" "
w 0 0x9a
w 1 0x01
s pc 0
s ix 0x01
s cf 1
i
d
q
" "ix=0x03"

# 10. 絶対アドレス（プログラム領域）: ADC IX, [d] (Opcode: 0x9C)
run_test "ADC IX, [d]" "
w 0 0x9c
w 1 0x30
w 0x30 0x01
s pc 0
s ix 0x01
s cf 1
i
d
q
" "ix=0x03"

# 11. 絶対アドレス（データ領域）: ADC IX, (d) (Opcode: 0x9D)
run_test "ADC IX, (d)" "
w 0 0x9d
w 1 0x90
w 0x190 0x01
s pc 0
s ix 0x01
s cf 1
i
d
q
" "ix=0x03"

# 12. IX修飾（プログラム領域）: ADC IX, [IX+d] (Opcode: 0x9E)
run_test "ADC IX, [IX+d]" "
w 0 0x9e
w 1 0x10
w 0x90 0x01
s pc 0
s ix 0x80
s cf 1
i
d
q
" "ix=0x82"

# 13. IX修飾（データ領域）: ADC IX, (IX+d) (Opcode: 0x9F)
run_test "ADC IX, (IX+d)" "
w 0 0x9f
w 1 0x10
w 0x190 0x01
s pc 0
s ix 0x80
s cf 1
i
d
q
" "ix=0x82"

# 14. Carry発生確認
run_test "ADC carry" "
w 0 0x92
w 1 0xff
s pc 0
s acc 0xff
s cf 1
i
d
q
" "acc=0xff.*cf=1"

# 15. VFセット例
run_test "ADC VF" "
w 0 0x92
w 1 0x01
s pc 0
s acc 0x7f
s cf 0
i
d
q
" "acc=0x80.*vf=1"

# 16. CF=0 なら ADD と同じ動作
run_test "ADC CF=0" "
w 0 0x92
w 1 0x02
s pc 0
s acc 0x01
s cf 0
i
d
q
" "acc=0x03.*cf=0.*vf=0.*nf=0.*zf=0"

# 17. ZF=1 になる例
run_test "ADC ZF" "
w 0 0x92
w 1 0x00
s pc 0
s acc 0xff
s cf 1
i
d
q
" "acc=0x00.*cf=1.*vf=0.*nf=0.*zf=1"

# 18. 1語命令でPCが+1
run_test "PC inc (1-byte) ADC ACC, ACC" "
w 0 0x90
s pc 0
s cf 0
i
q
" "CPU0,PC=0x1>"

# 19. 2語命令でPCが+2
run_test "PC inc (2-byte) ADC ACC, d" "
w 0 0x92
w 1 0x00
s pc 0
s cf 0
i
q
" "CPU0,PC=0x2>"

# --- テストサマリ ---

print_summary
if [ "$FAIL_COUNT" -ne 0 ]; then exit 1; fi

exit 0
