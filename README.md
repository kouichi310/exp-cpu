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

## Compile and Run the Example

First compile the ToyCC source to a text file:

```
$ make build examples/sample.tc
```

Then execute the resulting program with the simulator. The simulator will load the program, run until `HLT`, and display the values stored in memory beginning at address `0x100`.

The simulator allows up to 20,000,000 instructions to execute before it reports "Too Many Instructions are Executed".

Variables are allocated sequentially starting at address `0x100`. Arrays occupy contiguous regions beginning at their base address.

```
$ make run examples/sample.txt
```

Running this command produces output similar to:

```
$ make run examples/sample.txt
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
$ make build examples/fizz_buzz.tc
$ make run examples/fizz_buzz.txt
echo "r examples/fizz_buzz.txt\nc\nm 0x100\nq" | cpu/cpu_project_2
CPU0,PC=0x0> CPU0,PC=0x0> Program Halted.
CPU0,PC=0x5c>     | 100:  15 02 00 00 00 00 00 00    | 108:  00 00 00 00 00 00 00 00
CPU0,PC=0x5c>
```

The values `15`, `02` and `00` correspond to the variables `i`, `c3` and `c5`. After twenty iterations the program ends with `i = 21` (`0x15`), `c3 = 2` and `c5 = 0`, confirming correct execution.


### bubble\_sort

```
$ make build examples/bubble_sort.tc
$ make run examples/bubble_sort.txt
echo "r examples/bubble_sort.txt\nc\nm 0x100\nq" | cpu/cpu_project_2
CPU0,PC=0x0> CPU0,PC=0x0> Program Halted.
CPU0,PC=0xc5>     | 100:  01 02 03 04 05 05 04 04    | 108:  00 00 00 00 00 00 00 00
CPU0,PC=0xc5>
```

The five bytes at `0x100` hold the sorted array.  The remaining values
are the loop counters `i` and `j` and the temporary variable `tmp`.  At
termination `i = 5`, `j = 4` and `tmp = 4`, so they appear as `05 04 04`
instead of `00`.


### quick\_sort

```
$ make build examples/quick_sort.tc
$ make run examples/quick_sort.txt
echo "r examples/quick_sort.txt\nc\nm 0x100\nq" | cpu/cpu_project_2
CPU0,PC=0x0> CPU0,PC=0x0> Program Halted.
CPU0,PC=0xc5>     | 100:  01 02 03 04 05 05 04 02    | 108:  00 00 00 00 00 00 00 00
CPU0,PC=0xc5>
```

After rewriting the example the array is sorted correctly.  Like the
bubble sort program, the trailing bytes represent the loop counters and
temporary variable (`i = 5`, `j = 4`, `tmp = 2`).


## Clean

To remove build artifacts, run:

```
$ make clean
```
