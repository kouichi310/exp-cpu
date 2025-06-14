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
" "acc=0x04"

# 3. レジスタ指定: SUB IX, ACC (Opcode: 0xA8)
run_test "SUB IX, ACC" "
w 0 0xa8
s pc 0
s ix 0x05
s acc 0x03
i
d
q
" "ix=0x02"

# 4. VFセット例: 0x80 - 0x01
run_test "SUB sets VF" "
w 0 0xa2
w 1 0x01
s pc 0
s acc 0x80
i
d
q
" "acc=0x7f.*vf=1.*nf=0.*zf=0"

# 5. NFセット例: 0x01 - 0x02
run_test "SUB sets NF" "
w 0 0xa2
w 1 0x02
s pc 0
s acc 0x01
i
d
q
" "acc=0xff.*nf=1.*zf=0"

# 6. CFは変化しない
run_test "SUB preserves CF" "
w 0 0xa2
w 1 0x01
s pc 0
s acc 0x02
s cf 1
i
d
q
" "acc=0x01.*cf=1"

# 7. 1語命令でPCが+1
run_test "PC inc (1-byte) SUB ACC, ACC" "
w 0 0xa0
s pc 0
i
d
q
" "CPU0,PC=0x1>"

# 8. 2語命令でPCが+2
run_test "PC inc (2-byte) SUB ACC, d" "
w 0 0xa2
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
