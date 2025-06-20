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

## Run the Example

Use `make run` to compile the example and execute it on the simulator. The simulator will load the generated program, run until `HLT`, and display the values stored in memory locations `0x100` and `0x101`.

```
$ make run
```

## Clean

To remove build artifacts, run:

```
$ make clean
```
