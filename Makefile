CPU_DIR=cpu
TOYCC_DIR=toycc
CPU_BIN=$(CPU_DIR)/cpu_project_2
TOYCC_BIN=$(TOYCC_DIR)/toycc_compiler

EXAMPLE_SRC=examples/sample.tc
EXAMPLE_BIN=examples/sample.txt

.PHONY: all clean run

all: $(CPU_BIN) $(TOYCC_BIN)

$(CPU_BIN):
	$(MAKE) -C $(CPU_DIR)

$(TOYCC_BIN):
	$(MAKE) -C $(TOYCC_DIR)

$(EXAMPLE_BIN): $(EXAMPLE_SRC) $(TOYCC_BIN)
	$(TOYCC_BIN) $(EXAMPLE_SRC) $(EXAMPLE_BIN)

run: all $(EXAMPLE_BIN)
	echo "r $(EXAMPLE_BIN)\nc\nm 0x100\nm 0x101\nq" | $(CPU_BIN)

clean:
	$(MAKE) -C $(CPU_DIR) clean
	$(MAKE) -C $(TOYCC_DIR) clean
	rm -f $(EXAMPLE_BIN)
