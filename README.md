# exp-cpu project

このリポジトリには、シンプルなCPUシミュレータ（`cpu/`）と、最小限のCライクなコンパイラ（`toycc/`）が含まれています。ルートディレクトリには、両コンポーネントをビルドし、サンプルプログラムを実行するためのMakefileが用意されています。

## ビルド方法

リポジトリのルートで `make` を実行することで、シミュレータとコンパイラの両方がビルドされます。

`make`

## サンプルプログラム

ToyCC 用に記述された小さなサンプルプログラムが `examples/sample.tc` にあります。

```c
byte x;
byte y;
x = 1;
y = x + 2;
````

このソースコードをコンパイルすると、`examples/sample.txt` が生成されます。このファイルはシミュレータによって読み込まれます。ファイルには `.text` セクション（命令）と `.data` セクション（初期メモリ）が含まれます。変数は、コードによって変更されない限り、すべて0で初期化されます。

## サンプルのコンパイルと実行

まず、ToyCC ソースコードをテキストファイルにコンパイルします：

`$ make build examples/sample.tc`

次に、シミュレータでこのプログラムを実行します。シミュレータはプログラムを読み込み、`HLT` 命令まで実行し、アドレス `0x100` からのメモリ内容を表示します。

シミュレータは最大 20,000,000 命令まで実行可能で、それを超えると "Too Many Instructions are Executed" の警告が出ます。

変数は `0x100` から順に連続して割り当てられます。配列も同様に、基底アドレスから連続した領域を使用します。

```
$ make run examples/sample.txt
```

このコマンドの出力例：

```
$ make run examples/sample.txt
echo "r examples/sample.txt\nc\nm 0x100\nq" | cpu/cpu_project_2
CPU0,PC=0x0> CPU0,PC=0x0> Program Halted.
CPU0,PC=0xc>     | 100:  01 03 00 00 00 00 00 00    | 108:  00 00 00 00 00 00 00 00
CPU0,PC=0xc>
```

アドレス `0x100` に現れるバイト列 `01` と `03` は、ソースプログラムの `x = 1` および `y = 3` に対応しており、プログラムが正しく実行されたことが確認できます。

## 追加のサンプル

同じ方法で `examples` ディレクトリ内の他のプログラムも実行できます。以下に、いくつかの例とその出力を示します。

### fizz\_buzz

```
$ make build examples/fizz_buzz.tc
$ make run examples/fizz_buzz.txt
echo "r examples/fizz_buzz.txt\nc\nm 0x100\nq" | cpu/cpu_project_2
CPU0,PC=0x0> CPU0,PC=0x0> Program Halted.
CPU0,PC=0x5c>     | 100:  15 02 00 00 00 00 00 00    | 108:  00 00 00 00 00 00 00 00
CPU0,PC=0x5c>
```

値 `15`、`02`、`00` はそれぞれ `i`、`c3`、`c5` に対応します。20回のループ後、`i = 21`（16進数で `0x15`）、`c3 = 2`、`c5 = 0` となっており、正しく動作しています。

### bubble\_sort

```
$ make build examples/bubble_sort.tc
$ make run examples/bubble_sort.txt
echo "r examples/bubble_sort.txt\nc\nm 0x100\nq" | cpu/cpu_project_2
CPU0,PC=0x0> CPU0,PC=0x0> Program Halted.
CPU0,PC=0xc5>     | 100:  01 02 03 04 05 05 04 04    | 108:  00 00 00 00 00 00 00 00
CPU0,PC=0xc5>
```

アドレス `0x100` からの5バイトは整列済みの配列を示しています。続くバイトはループ変数 `i`、`j` および一時変数 `tmp` で、終了時の値は `i = 5`、`j = 4`、`tmp = 4`（つまり `05 04 04`）となっています。

### quick\_sort

```
$ make build examples/quick_sort.tc
$ make run examples/quick_sort.txt
echo "r examples/quick_sort.txt\nc\nm 0x100\nq" | cpu/cpu_project_2
CPU0,PC=0x0> CPU0,PC=0x0> Program Halted.
CPU0,PC=0xc5>     | 100:  01 02 03 04 05 05 04 02    | 108:  00 00 00 00 00 00 00 00
CPU0,PC=0xc5>
```

修正後のクイックソートのサンプルでは、配列が正しく整列されています。バブルソートと同様に、末尾の値はループカウンタと一時変数を表しており、それぞれ `i = 5`、`j = 4`、`tmp = 2` を示します。

## クリーンアップ

ビルド生成物を削除するには、以下を実行します：

`$ make clean`