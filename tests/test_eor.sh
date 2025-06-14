#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
BIN="$SCRIPT_DIR/../cpu_project_2"

PASS_COUNT=0
FAIL_COUNT=0
TEST_COUNT=0

run_test() {
  TEST_NAME=$1
  COMMANDS=$2
  EXPECTED=$3

  TEST_COUNT=$((TEST_COUNT + 1))
  echo "--- Running test: $TEST_NAME ---"

  output=$("$BIN" <<EOS 2>&1
${COMMANDS}
EOS
)

  if echo "$output" | grep -q "$EXPECTED"; then
    echo "PASS"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "FAIL"
    echo "====DEBUG INFO====="
    echo "$output"
    echo "==================="
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
  echo
}

# --- EOR命令のテストケース ---
# 0. レジスタ指定: EOR ACC, ACC (Opcode: 0xC0)
run_test "EOR ACC, ACC" "
w 0 0xc0
s pc 0
s acc 0xff
s nf 0
s zf 0
i
d
q
" "acc=0x0.*nf=0.*zf=1"

# 1. レジスタ指定: EOR ACC, IX (Opcode: 0xC1)
run_test "EOR ACC, IX" "
w 0 0xc1
s pc 0
s acc 0xf0
s ix 0x0f
i
d
q
" "acc=0xff.*nf=1.*zf=0"

# 2. 即値: EOR ACC, d (Opcode: 0xC2)
run_test "EOR ACC, d" "
w 0 0xc2
w 1 0x0f
s pc 0
s acc 0xf0
i
d
q
" "acc=0xff"

# 3. 絶対アドレス（プログラム領域）: EOR ACC, [d] (Opcode: 0xC4)
run_test "EOR ACC, [d]" "
w 0 0xc4
w 1 0x80
w 0x80 0x55
s pc 0
s acc 0xaa
i
d
q
" "acc=0xff"

# 4. レジスタ指定: EOR IX, ACC (Opcode: 0xC8)
run_test "EOR IX, ACC" "
w 0 0xc8
s pc 0
s ix 0x55
s acc 0xaa
i
d
q
" "ix=0xff"

# 5. 絶対アドレス（データ領域）: EOR ACC, (d) (Opcode: 0xC5)
run_test "EOR ACC, (d)" "
w 0 0xc5
w 1 0x88
w 0x188 0x55
s pc 0
s acc 0xaa
i
d
q
" "acc=0xff"

# 6. IX修飾（プログラム領域）: EOR ACC, [IX+d] (Opcode: 0xC6)
run_test "EOR ACC, [IX+d]" "
w 0 0xc6
w 1 0x30
w 0x90 0x0f
s pc 0
s acc 0xf0
s ix 0x60
i
d
q
" "acc=0xff"

# 7. IX修飾（データ領域）: EOR ACC, (IX+d) (Opcode: 0xC7)
run_test "EOR ACC, (IX+d)" "
w 0 0xc7
w 1 0x40
w 0x1a0 0x0f
s pc 0
s acc 0xf0
s ix 0x60
i
d
q
" "acc=0xff"

# 8. レジスタ指定: EOR IX, IX (Opcode: 0xC9)
run_test "EOR IX, IX" "
w 0 0xc9
s pc 0
s ix 0xaa
s nf 0
s zf 0
i
d
q
" "ix=0x0.*nf=0.*zf=1"

# 9. 即値: EOR IX, d (Opcode: 0xCA)
run_test "EOR IX, d" "
w 0 0xca
w 1 0x0f
s pc 0
s ix 0xf0
i
d
q
" "ix=0xff"

# 10. 絶対アドレス（プログラム領域）: EOR IX, [d] (Opcode: 0xCC)
run_test "EOR IX, [d]" "
w 0 0xcc
w 1 0x80
w 0x80 0x55
s pc 0
s ix 0xaa
i
d
q
" "ix=0xff"

# 11. 絶対アドレス（データ領域）: EOR IX, (d) (Opcode: 0xCD)
run_test "EOR IX, (d)" "
w 0 0xcd
w 1 0x88
w 0x188 0x55
s pc 0
s ix 0xaa
i
d
q
" "ix=0xff"

# 12. IX修飾（プログラム領域）: EOR IX, [IX+d] (Opcode: 0xCE)
run_test "EOR IX, [IX+d]" "
w 0 0xce
w 1 0x31
w 0x91 0x99
s pc 0
s ix 0x60
i
d
q
" "ix=0xf9"

# 13. IX修飾（データ領域）: EOR IX, (IX+d) (Opcode: 0xCF)
run_test "EOR IX, (IX+d)" "
w 0 0xcf
w 1 0x41
w 0x1a1 0xbb
s pc 0
s ix 0x60
i
d
q
" "ix=0xdb"

# 14. VFが0にリセットされCFは不変
run_test "EOR clears VF" "
w 0 0xc0
s pc 0
s acc 0xff
s cf 1
s vf 1
i
d
q
" "cf=1.*vf=0"

# 15. 1語命令: EOR ACC, ACC (Opcode 0xC0) で PC が +1
run_test "PC inc (1-byte) EOR ACC, ACC" "
w 0 0xc0
s pc 0
s acc 0x01
i
d
q
" "CPU0,PC=0x1>"

# 16. 2語命令: EOR ACC, d (Opcode 0xC2) で PC が +2
run_test "PC inc (2-byte) EOR ACC, d" "
w 0 0xc2
w 1 0xff
s pc 0
s acc 0x00
i
d
q
" "CPU0,PC=0x2>"

# --- テストサマリ ---
echo "===================="
echo "Test Summary"
echo "===================="
echo "TOTAL: $TEST_COUNT, PASS: $PASS_COUNT, FAIL: $FAIL_COUNT"
echo

if [ "$FAIL_COUNT" -ne 0 ]; then
  exit 1
fi

exit 0
