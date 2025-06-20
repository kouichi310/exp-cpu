CPU_DIR=cpu
TOYCC_DIR=toycc
CPU_BIN=$(CPU_DIR)/cpu_project_2
TOYCC_BIN=$(TOYCC_DIR)/toycc_compiler

EXAMPLE=sample
ifneq ($(filter fizz_buzz,$(MAKECMDGOALS)),)
EXAMPLE=fizz_buzz
endif

EXAMPLE_SRC=examples/$(EXAMPLE).tc
EXAMPLE_BIN=examples/$(EXAMPLE).txt

.PHONY: all clean run fizz_buzz

all: $(CPU_BIN) $(TOYCC_BIN)

$(CPU_BIN):
	$(MAKE) -C $(CPU_DIR)

$(TOYCC_BIN):
	$(MAKE) -C $(TOYCC_DIR)

examples/%.txt: examples/%.tc $(TOYCC_BIN)
	$(TOYCC_BIN) $< $@

run: all $(EXAMPLE_BIN)
	echo "r $(EXAMPLE_BIN)\nc\nd\nq" | $(CPU_BIN)

fizz_buzz:

clean:
	$(MAKE) -C $(CPU_DIR) clean
	$(MAKE) -C $(TOYCC_DIR) clean
	rm -f examples/*.txt
