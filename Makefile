CPU_DIR=cpu
TOYCC_DIR=toycc
CPU_BIN=$(CPU_DIR)/cpu_project_2
TOYCC_BIN=$(TOYCC_DIR)/toycc_compiler

TARGET_FILE := $(word 2,$(MAKECMDGOALS))
TARGET_TXT  := $(patsubst %.tc,%.txt,$(TARGET_FILE))

.PHONY: all build run clean $(TARGET_FILE)

all: $(CPU_BIN) $(TOYCC_BIN)

$(TARGET_FILE): ; @# suppress "No rule to make target" warnings

$(CPU_BIN):
	$(MAKE) -C $(CPU_DIR)

$(TOYCC_BIN):
	$(MAKE) -C $(TOYCC_DIR)

build: all
	@if [ -z "$(TARGET_FILE)" ]; then \
	    echo "Usage: make build <source.tc>"; exit 1; \
	fi
	$(TOYCC_BIN) $(TARGET_FILE) $(TARGET_TXT)

run: $(CPU_BIN)
	@if [ -z "$(TARGET_FILE)" ]; then \
	    echo "Usage: make run <program.txt>"; exit 1; \
	fi
	echo "r $(TARGET_FILE)\nc\nm 0x100\nq" | $(CPU_BIN)

clean:
	$(MAKE) -C $(CPU_DIR) clean
	$(MAKE) -C $(TOYCC_DIR) clean
	rm -f examples/*.txt
