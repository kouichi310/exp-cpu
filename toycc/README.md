# ToyCC

教育用CPUシミュレータ向けの簡易Cライクコンパイラです。

# ToyCC 言語仕様

ToyCC は教育用CPUシミュレータ向けに設計された最小構成の C ライク言語です。
ここでは構文ルールやメモリ配置、出力フォーマットについて詳しく解説します。

## 基本方針
- データ型は 1 バイトの `byte` のみを扱います。
- 関数は存在せず、プログラムはトップレベルの文が並ぶだけです。
- 配列要素や変数はすべて 0x100 以降のメモリに割り当てられます。

## 構文
主な構文要素は次の通りです。

```
program    ::= { statement }
statement  ::= decl | assign | array_assign | if_stmt | while_stmt
              | in_stmt | out_stmt | label | 'hlt' ';'
decl       ::= 'byte' ident ['[' number ']'] ';'
assign     ::= ident '=' expr ';'
array_assign ::= ident '[' expr ']' '=' expr ';'
if_stmt    ::= 'if' condition '{' { statement } '}' [ 'else' '{' { statement } '}' ]
while_stmt ::= 'while' condition '{' { statement } '}'
in_stmt    ::= 'in' ident ';'
out_stmt   ::= 'out' expr ';'
label      ::= ident ':'
expr       ::= term [ ('+'|'-') term ]
term       ::= ident | number | ident '[' expr ']'
condition  ::= '(' term ('=='|'!='|'<'|'<='|'>'|'>=') term ')'
```

数値リテラルは 10 進または `0x` から始まる 16 進表記が使用できます。

## メモリレイアウト
宣言された変数は順番にデータメモリ 0x100 番地以降へ割り当てられます。
配列は連続した領域を確保します。コンパイラ内部では配列代入のために
0x1FE と 0x1FF 番地を作業用として使用します。

## 生成されるファイル
コンパイル結果はテキスト形式で以下のセクションを持ちます。

- `.text 0` : 以降 1 行 1 バイトで命令コードを 16 進表記したもの。
- `.data 0` : (変数が存在する場合のみ) 初期化データの列。

シミュレータの `r` コマンドにそのまま渡せる形式となっています。
末尾には自動的に `HLT`(0x0F) 命令が付加されます。

## コンパイルの流れ
```
$ make -C toycc
$ ./toycc/toycc source.tc output.txt
```
`output.txt` をシミュレータに読み込ませて実行します。

## 参考
より簡潔な仕様概要は `memo.md` にも記載されています。


## 特徴
- 8bit `byte` 型のみを扱うシンプルな言語
- 変数宣言と代入式(加算・減算)をサポート
- コンパイル時に未宣言変数を検出する静的解析を実施
- 出力はシミュレータの `r` コマンドで読み込めるテキスト形式

## 使い方
```bash
$ make -C toycc
$ ./toycc/toycc source.tc output.txt
```
生成された `output.txt` をシミュレータで `r` コマンドに渡してプログラムを
ロードできます。

## ソースコード構成
- `src/toycc.c` コンパイラ本体
- `docs/仕様.md` 言語仕様などのドキュメント
