# 教育用CPUシミュレータ

## ディレクトリ構成

```
cpu-sim/                 ＜プロジェクト・ルート＞
│
├─ include/              ＜公開ヘッダファイル群＞
│   ├─ cpuboard.h        ; CPUのコアリソース(構造体 Cpub)や型の定義
│   ├─ isa.h             ; 命令セットアーキテクチャ(Opcode, Instruction構造体等)の定義
│   ├─ isa_table.h       ; 命令実行関数のテーブル宣言
│   ├─ cpu_fetch.h       ; fetchステージ関数の宣言
│   ├─ cpu_decode.h      ; decodeステージ関数の宣言
│   ├─ inst_*.h          ; 各命令の実行ハンドラ(isa_ld)の宣言
│   └─ mem.h             ; メモリアクセスAPI(mem_read, mem_write)の宣言
│
├─ src/                  ＜ソースコード実装＞
│   ├─ main.c            ; シミュレータのメイン関数、コマンドインタプリタ
│   ├─ cpuboard.c        ; 命令実行サイクル(step関数)の実装
│   ├─ cpu_fetch.c       ; fetchステージの実装
│   ├─ cpu_decode.c      ; decodeステージの実装
│   ├─ isa_table.c       ; 命令実行テーブルの初期化
│   ├─ inst_ld.c         ; LD命令の実行ロジック
│   └─ mem.c             ; メモリアクセスAPIの実装
│
├─ tests/                ＜テスト用スクリプト＞
│   ├─ run_tests.sh      ; すべてのテスト(test_*.sh)をビルドして実行する
│   └─ test_*.sh         ; 各命令の網羅的テストスイート
│
├─ docs/                 ＜ドキュメント＞
│   └─ memo.md           ; CPUとシミュレータの仕様に関するMarkdown形式のメモ
│
└─ .gitignore            ; Gitの管理対象外ファイルを指定
```

### 各ファイルの説明

#### `include/`
* `cpuboard.h`: CPUのレジスタ、メモリ、フラグなどを含むコア構造体`Cpub`を定義します。
* `isa.h`: `Opcode`やアドレッシングモードの`enum`、デコードされた命令を保持する`Instruction`構造体を定義します。
* `isa_table.h`: 命令コードと実行関数を対応付けるテーブル`isa_exec_table`を外部宣言します。
* `cpu_fetch.h`, `cpu_decode.h`: それぞれ`fetch`, `decode`関数のプロトタイプを宣言します。
* `inst_ld.h`: `LD`命令の実行関数`isa_ld`のプロトタイプを宣言します。
* `mem.h`: メモリ操作関数`mem_read`, `mem_write`のプロトタイプを宣言します。

#### `src/`
* `main.c`: シミュレータのコマンド（`i`, `d`, `w`など）を解釈・実行するメインループです。
* `cpuboard.c`: 1命令の実行サイクルを制御する`step`関数を実装しています。
* `cpu_fetch.c`: メモリから命令語を読み出し、命令のフィールドを分離します。
* `cpu_decode.c`: アドレッシングモードに基づき、実効アドレスや即値を計算します。
* `isa_table.c`: 命令コードとそれを処理する関数ポインタの対応表を定義・初期化します。
* `inst_opcode.c`: 各命令の具体的な処理を実装しています。
* `mem.c`: メモリへの読み書きを行う関数を実装しています。

#### `tests/`
* `run_tests.sh`: このディレクトリ内の`test_*.sh`という名前のスクリプトを順次実行します。
* `test_opcode.sh`: 各命令の動作を検証するための具体的なテストケースが記述されています。