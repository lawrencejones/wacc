# WACC Compiler Makefile - Group 27
COFFEE := coffee
COFFEE_FLAGS := --compile --bare
PEG := pegjs

# Setup file locations
SRC_DIR := src
LIB_DIR := lib

# Glob all the coffee source
SRC := $(wildcard $(SRC_DIR)/*.coffee | sort)
LIB := $(SRC:$(SRC_DIR)/%.coffee=$(LIB_DIR)/%.js) lib/parser.js

.PHONY: all clean rebuild

# Phony all target
all: $(LIB)
	@-echo "Finished building wacc."

# Phony clean target
clean:
	@-echo "Cleaning *.js files"
	@-rm -f $(LIB)

# Phony rebuild target
rebuild: clean all

# The pegjs generated parser
lib/parser.js: src/grammar.pegjs
	@-echo "  Compiling $@"
	@-$(PEG) $< $@

# Rule for all other coffee files
lib/%.js: src/%.coffee
	@-echo "  Compiling $@"
	@-$(COFFEE) $(COFFEE_FLAGS) -o $(LIB_DIR) $<
