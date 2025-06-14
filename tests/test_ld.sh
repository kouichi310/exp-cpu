#!/bin/sh
set -e
SCRIPT_DIR="$(dirname "$0")"
BIN="$SCRIPT_DIR/../cpu_project_2"

output=$("$BIN" <<'EOS' 2>&1
w 0 0x24
w 1 0x60
w 0x60 0x55
s pc 0
s acc 0
s ix 0
i
d
q
EOS
)

echo "$output" | grep -q "acc=0x55"
