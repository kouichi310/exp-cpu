# exp-cpu Example Usage

This repository contains a simple CPU simulator (`cpu/`) and a minimal C-like compiler (`toycc/`). A top-level Makefile is provided to build both components and run a sample program.

## Build

Run `make` in the repository root to build the simulator and the compiler.

```
$ make
```

## Example Program

A small example written for ToyCC is located at `examples/sample.tc`:

```c
byte x;
byte y;
x = 1;
y = x + 2;
```

Compiling this source produces `examples/sample.txt`, which can be loaded by the simulator. The file contains a `.text` section with instructions followed by a `.data` section for initial memory. Variables start at zero unless changed by code.

### Additional ToyCC Examples

ToyCC now supports `if`/`else` statements and `while` loops in addition to
variable declarations and assignments. It also offers rudimentary arrays and
basic I/O using `in` and `out` statements. Arrays are backed by consecutive
memory addresses and accessed via `name[index]`. Example programs demonstrating
these features are provided in the `examples` directory (`bubble_sort.tc`,
`quicksort.tc` and `fizz_buzz.tc`).

## Run the Example

Use `make run` to compile the example and execute it on the simulator. The simulator will load the generated program, run until `HLT`, and display the values stored in memory beginning at address `0x100`.

The simulator now allows up to 20,000,000 instructions to execute before it reports "Too Many Instructions are Executed".

Variables are allocated sequentially starting at address `0x100`. Arrays occupy
contiguous regions beginning at their base address.

```
$ make run
```

Running this command produces output similar to:

```
$ make run
echo "r examples/sample.txt\nc\nm 0x100\nq" | cpu/cpu_project_2
CPU0,PC=0x0> CPU0,PC=0x0> Program Halted.
CPU0,PC=0xc>     | 100:  01 03 00 00 00 00 00 00    | 108:  00 00 00 00 00 00 00 00
CPU0,PC=0xc>
```

The bytes `01` and `03` starting at address `0x100` correspond to `x = 1` and
`y = 3` from the source program, confirming the execution completed
successfully.

## Additional Examples

The same approach works for the other programs in the `examples` directory.
The sections below show the output of running several of them and inspecting
memory at `0x100`.

### fizz\_buzz

```
$ make run fizz_buzz
toycc/toycc_compiler examples/fizz_buzz.tc examples/fizz_buzz.txt
echo "r examples/fizz_buzz.txt\nc\nm 0x100\nq" | cpu/cpu_project_2
CPU0,PC=0x0> CPU0,PC=0x0> Program Halted.
CPU0,PC=0x5c>     | 100:  15 02 00 00 00 00 00 00    | 108:  00 00 00 00 00 00 00 00
CPU0,PC=0x5c>
```

The values `15`, `02` and `00` correspond to the variables `i`, `c3` and `c5`. After twenty iterations the program ends with `i = 21` (`0x15`), `c3 = 2` and `c5 = 0`, confirming correct execution.


### bubble\_sort

```
$ make run bubble_sort
toycc/toycc_compiler examples/bubble_sort.tc examples/bubble_sort.txt
echo "r examples/bubble_sort.txt\nc\nm 0x100\nq" | cpu/cpu_project_2
CPU0,PC=0x0> CPU0,PC=0x0> Program Halted.
CPU0,PC=0x89>     | 100:  05 01 04 04 04 05 04 04    | 108:  00 00 00 00 00 00 00 00
CPU0,PC=0x89>
```

The dump begins with the five array elements followed by `i`, `j` and `tmp`.
After the program halts the array contents are `5, 1, 4, 4, 4`. Even with the execution limit raised to 20,000,000 instructions the routine does not completely sort the data.


### quick\_sort

```
$ make run quick_sort
toycc/toycc_compiler examples/quick_sort.tc examples/quick_sort.txt
echo "r examples/quick_sort.txt\nc\nm 0x100\nq" | cpu/cpu_project_2
CPU0,PC=0x0> CPU0,PC=0x0> Too Many Instructions are Executed.
CPU0,PC=0x9c>     | 100:  05 04 03 02 05 00 77 00    | 108:  65 11 b2 04 75 11 30 43
CPU0,PC=0x9c>
```

The quick sort example also fails to finish sorting. Despite the higher instruction budget the simulator eventually stops with "Too Many Instructions are Executed" and the array remains `5, 4, 3, 2, 1`.


## Clean

To remove build artifacts, run:

```
$ make clean
```
