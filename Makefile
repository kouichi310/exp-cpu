CC=gcc
CFLAGS=-std=c11 -Wall -Iinclude

SRC = $(wildcard src/*.c)
BIN = cpu_project_2

$(BIN): $(SRC)
	$(CC) $(CFLAGS) -o $@ $(SRC)

clean:
	rm -f $(BIN)

test:
	sh tests/run_tests.sh