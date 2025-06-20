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

# --- AND命令のテストケース ---
# 0. レジスタ指定: AND ACC, ACC (Opcode: 0xE0)
run_test "AND ACC, ACC" "
w 0 0xe0
s pc 0
s acc 0xf0
i
d
q
" "acc=0xf0.*nf=1.*zf=0"

# 1. レジスタ指定: AND ACC, IX (Opcode: 0xE1)
run_test "AND ACC, IX" "
w 0 0xe1
s pc 0
s acc 0xf0
s ix 0x0f
i
d
q
" "acc=0x0.*nf=0.*zf=1"

# 2. 即値: AND ACC, d (Opcode: 0xE2)
run_test "AND ACC, d" "
w 0 0xe2
w 1 0x0f
s pc 0
s acc 0xf0
i
d
q
" "acc=0x0.*nf=0.*zf=1"

# 3. 絶対アドレス（プログラム領域）: AND ACC, [d] (Opcode: 0xE4)
run_test "AND ACC, [d]" "
w 0 0xe4
w 1 0x80
w 0x80 0x55
s pc 0
s acc 0xff
i
d
q
" "acc=0x55.*nf=0.*zf=0"

# 4. 絶対アドレス（データ領域）: AND ACC, (d) (Opcode: 0xE5)
run_test "AND ACC, (d)" "
w 0 0xe5
w 1 0x88
w 0x188 0xf0
s pc 0
s acc 0x0f
i
d
q
" "acc=0x0.*nf=0.*zf=1"

# 5. IX修飾（プログラム領域）: AND ACC, [IX+d] (Opcode: 0xE6)
run_test "AND ACC, [IX+d]" "
w 0 0xe6
w 1 0x10
w 0x90 0xaa
s pc 0
s acc 0xff
s ix 0x80
i
d
q
" "acc=0xaa"

# 6. IX修飾（データ領域）: AND ACC, (IX+d) (Opcode: 0xE7)
run_test "AND ACC, (IX+d)" "
w 0 0xe7
w 1 0x10
w 0x190 0x0f
s pc 0
s acc 0xf0
s ix 0x80
i
d
q
" "acc=0x0.*zf=1"

# 7. レジスタ指定: AND IX, ACC (Opcode: 0xE8)
run_test "AND IX, ACC" "
w 0 0xe8
s pc 0
s ix 0xf0
s acc 0x0f
i
d
q
" "ix=0x0.*zf=1"

# 8. レジスタ指定: AND IX, IX (Opcode: 0xE9)
run_test "AND IX, IX" "
w 0 0xe9
s pc 0
s ix 0xaa
i
d
q
" "ix=0xaa.*nf=1.*zf=0"

# 9. 即値: AND IX, d (Opcode: 0xEA)
run_test "AND IX, d" "
w 0 0xea
w 1 0x0f
s pc 0
s ix 0xf0
i
d
q
" "ix=0x0.*zf=1"

# 10. 絶対アドレス（プログラム領域）: AND IX, [d] (Opcode: 0xEC)
run_test "AND IX, [d]" "
w 0 0xec
w 1 0x20
w 0x20 0x33
s pc 0
s ix 0xf0
i
d
q
" "ix=0x30"

# 11. 絶対アドレス（データ領域）: AND IX, (d) (Opcode: 0xED)
run_test "AND IX, (d)" "
w 0 0xed
w 1 0x88
w 0x188 0x0f
s pc 0
s ix 0xf0
i
d
q
" "ix=0x0.*zf=1"

# 12. IX修飾（プログラム領域）: AND IX, [IX+d] (Opcode: 0xEE)
run_test "AND IX, [IX+d]" "
w 0 0xee
w 1 0x10
w 0x90 0x0f
s pc 0
s ix 0x80
i
d
q
" "ix=0x0.*zf=1"

# 13. IX修飾（データ領域）: AND IX, (IX+d) (Opcode: 0xEF)
run_test "AND IX, (IX+d)" "
w 0 0xef
w 1 0x10
w 0x190 0xff
s pc 0
s ix 0x80
i
d
q
" "ix=0x80.*nf=1"

# 14. VFが0にリセットされCFは不変
run_test "AND clears VF" "
w 0 0xe0
s pc 0
s acc 0xff
s cf 1
s vf 1
i
d
q
" "cf=1.*vf=0"

# 15. 1語命令: AND ACC, ACC で PC が +1
run_test "PC inc (1-byte) AND" "
w 0 0xe0
s pc 0
i
d
q
" "CPU0,PC=0x1>"

# 16. 2語命令: AND ACC, d で PC が +2
run_test "PC inc (2-byte) AND" "
w 0 0xe2
w 1 0x00
s pc 0
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
