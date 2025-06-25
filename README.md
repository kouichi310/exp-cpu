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

Compiling this source produces `examples/sample.txt`, which can be loaded by the simulator.

### Additional ToyCC Examples

ToyCC now supports `if`/`else` statements and `while` loops in addition to
variable declarations and assignments. It also offers rudimentary arrays and
basic I/O using `in` and `out` statements. Arrays are backed by consecutive
memory addresses and accessed via `name[index]`. Example programs demonstrating
these features are provided in the `examples` directory (`bubble_sort.tc`,
`quicksort.tc` and `fizz_buzz.tc`).

## Run the Example

Use `make run` to compile the example and execute it on the simulator. The simulator will load the generated program, run until `HLT`, and display the values stored in memory locations `0x100` and `0x101`.

Variables are allocated sequentially starting at address `0x100`. Arrays occupy
contiguous regions beginning at their base address.

```
$ make run
```

To run a different example, append the file stem after `run`. For instance,
`fizz_buzz.tc` or `bubble_sort.tc` can be executed with:

```
$ make run fizz_buzz
```

```
$ make run bubble_sort
```

## Clean

To remove build artifacts, run:

```
$ make clean
```
