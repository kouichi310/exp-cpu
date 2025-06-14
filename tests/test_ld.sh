#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
BIN="$SCRIPT_DIR/../cpu_project_2"

# テストの成功・失敗をカウントする変数
PASS_COUNT=0
FAIL_COUNT=0
TEST_COUNT=0

# 各テストを実行し、結果を評価するヘルパー関数
run_test() {
  TEST_NAME=$1
  # シェル変数からヒアドキュメントへ値を渡すため、EOSのクオートを外す
  COMMANDS=$2
  EXPECTED_OUTPUT=$3

  TEST_COUNT=$((TEST_COUNT + 1))
  echo "--- Running test: $TEST_NAME ---"

  # シミュレータを実行し、出力をキャプチャ
  output=$("$BIN" <<EOS 2>&1
${COMMANDS}
EOS
)

  # 期待される出力が含まれているかチェック
  if echo "$output" | grep -q "$EXPECTED_OUTPUT"; then
    echo "PASS"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "FAIL"
    echo "====DEBUG INFO====="
    echo "$output"
    echo "==================="
    echo "EXPECTED: $EXPECTED_OUTPUT"
    echo "GOT: "
    echo "$output" | grep "acc="
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
  echo
}

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
" "acc=0xa0.*nf=1"

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
" "ix=0xb0.*nf=1"

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



# --- テストサマリ ---
echo "===================="
echo "Test Summary"
echo "===================="
echo "TOTAL: $TEST_COUNT, PASS: $PASS_COUNT, FAIL: $FAIL_COUNT"
echo

# 失敗したテストがあれば、スクリプトをエラーで終了させる
if [ "$FAIL_COUNT" -ne 0 ]; then
  exit 1
fi

exit 0