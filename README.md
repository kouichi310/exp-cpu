```
cpu-sim/                 ＜プロジェクト・ルート＞
│
├─ include/              ＜公開ヘッダ群（他ファイルから #include される）＞
│   ├─ cpuboard.h        ; レジスタ構造体・共通リソース定義
│   ├─ isa.h             ; Opcode/AddrMode/Instr 構造体
│   ├─ isa_table.h       ; exec ハンドラテーブル宣言
│   ├─ cpu_core.h        ; fetch / decode / exec 公開 API
│   ├─ alu.h             ; ALU ユーティリティ
│   ├─ mem.h             ; メモリアクセス API
│   └─ util.h            ; 汎用マクロ／トレース
│
├─ src/                  ＜実装ソース＞
│   ├─ main.c            ; 既存のコマンドインタプリタ（最小変更）
│   ├─ cpu_core.c        ; 小ステートマシン：fetch→decode→exec
│   ├─ cpu_fetch.c       ; PC→MAR→Mem→IR の 1 ステップ
│   ├─ cpu_decode.c      ; IR を Instr へ展開し即値読込み
│   ├─ isa_table.c       ; exec ハンドラ配列初期化
│   │
│   ├─ inst_loadstore.c  ; LD / ST 系（今回まずここを実装）
│   ├─ inst_arith.c      ; ADD / ADC / SUB / CMP …
│   ├─ inst_branch.c     ; BA / BNZ / JAL / JR …
│   ├─ inst_misc.c       ; NOP / HLT / シフト命令 など
│   │
│   ├─ alu.c             ; 8-bit ALU（加算・論理・シフト・フラグ生成）
│   ├─ mem.c             ; 内部メモリ・I/O バッファ read / write
│   └─ util.c            ; デバッグ用 hex ダンプ・ログ関数
│
├─ tests/                ＜動作確認用ソース・スクリプト＞
│   ├─ asm/              ; hand-written アセンブリ
│   │   ├─ st_abs.asm    ; ST 絶対アドレス単体テスト
│   │   └─ …             ; 追加テスト
│   └─ run_tests.sh      ; 連続実行＋diff チェック
│
├─ docs/                 ＜説明・レポート用＞
│   ├─ README.md
│   └─ design.md         ; フェッチ段／デコード段の説明図
│
└─ Makefile              ; make run, make test, make clean
```