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

# --- CMP命令のテストケース ---
# 0. レジスタ指定: CMP ACC, ACC (Opcode: 0xF0)
run_test "CMP ACC, ACC" "
w 0 0xf0
s pc 0
s acc 0x10
i
d
q
" "acc=0x10.*cf=0.*vf=0.*nf=0.*zf=1"

# 1. レジスタ指定: CMP ACC, IX (Opcode: 0xF1)
run_test "CMP ACC, IX" "
w 0 0xf1
s pc 0
s acc 0x05
s ix 0x03
i
d
q
" "cf=0.*vf=0.*nf=0.*zf=0"

# 2. 即値: CMP ACC, d (Opcode: 0xF2)
run_test "CMP ACC, d" "
w 0 0xf2
w 1 0x02
s pc 0
s acc 0x01
i
d
q
" "cf=1.*vf=0.*nf=1.*zf=0"

# 3. 絶対アドレス（プログラム領域）: CMP ACC, [d] (Opcode: 0xF4)
run_test "CMP ACC, [d]" "
w 0 0xf4
w 1 0x20
w 0x20 0x01
s pc 0
s acc 0x01
i
d
q
" "zf=1"

# 4. 絶対アドレス（データ領域）: CMP ACC, (d) (Opcode: 0xF5)
run_test "CMP ACC, (d)" "
w 0 0xf5
w 1 0x88
w 0x188 0x02
s pc 0
s acc 0x01
i
d
q
" "cf=1"

# 5. IX修飾（プログラム領域）: CMP ACC, [IX+d] (Opcode: 0xF6)
run_test "CMP ACC, [IX+d]" "
w 0 0xf6
w 1 0x10
w 0x90 0x01
s pc 0
s acc 0x02
s ix 0x80
i
d
q
" "cf=0"

# 6. IX修飾（データ領域）: CMP ACC, (IX+d) (Opcode: 0xF7)
run_test "CMP ACC, (IX+d)" "
w 0 0xf7
w 1 0x10
w 0x190 0x03
s pc 0
s acc 0x02
s ix 0x80
i
d
q
" "cf=1"

# 7. レジスタ指定: CMP IX, ACC (Opcode: 0xF8)
run_test "CMP IX, ACC" "
w 0 0xf8
s pc 0
s ix 0x05
s acc 0x05
i
d
q
" "zf=1"

# 8. レジスタ指定: CMP IX, IX (Opcode: 0xF9)
run_test "CMP IX, IX" "
w 0 0xf9
s pc 0
s ix 0x02
i
d
q
" "zf=1"

# 9. 即値: CMP IX, d (Opcode: 0xFA)
run_test "CMP IX, d" "
w 0 0xfa
w 1 0x05
s pc 0
s ix 0x03
i
d
q
" "cf=1"

# 10. 絶対アドレス（プログラム領域）: CMP IX, [d] (Opcode: 0xFC)
run_test "CMP IX, [d]" "
w 0 0xfc
w 1 0x20
w 0x20 0x02
s pc 0
s ix 0x02
i
d
q
" "zf=1"

# 11. 絶対アドレス（データ領域）: CMP IX, (d) (Opcode: 0xFD)
run_test "CMP IX, (d)" "
w 0 0xfd
w 1 0x88
w 0x188 0x04
s pc 0
s ix 0x03
i
d
q
" "cf=1"

# 12. IX修飾（プログラム領域）: CMP IX, [IX+d] (Opcode: 0xFE)
run_test "CMP IX, [IX+d]" "
w 0 0xfe
w 1 0x10
w 0x90 0x01
s pc 0
s ix 0x80
i
d
q
" "cf=0"

# 13. IX修飾（データ領域）: CMP IX, (IX+d) (Opcode: 0xFF)
run_test "CMP IX, (IX+d)" "
w 0 0xff
w 1 0x10
w 0x190 0x81
s pc 0
s ix 0x80
i
d
q
" "cf=1.*nf=1.*zf=0"

# 14. フラグテスト: オーバーフロー発生
run_test "CMP sets VF" "
w 0 0xf2
w 1 0x7f
s pc 0
s acc 0x80
i
d
q
" "vf=1"

# 15. 1語命令: CMP ACC, ACC で PC が +1
run_test "PC inc (1-byte) CMP" "
w 0 0xf0
s pc 0
i
d
q
" "CPU0,PC=0x1>"

# 16. 2語命令: CMP ACC, d で PC が +2
run_test "PC inc (2-byte) CMP" "
w 0 0xf2
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
