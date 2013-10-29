# WACC Compiler Makefile - Group 27
COFFEE := coffee
COFFEE_FLAGS := --compile --bare
PEG := pegjs

# Glob all the coffee source
SRC := $(wildcard src/*.coffee | sort)
LIB := $(SRC:src/%.coffee=lib/%.js) lib/parser.js

# Phony all target
all: $(LIB)

# The pegjs generated parser
lib/parser.js: src/grammar.pegjs
	$(PEG) $< $@

# Rule for all other coffee files
lib/%.js: src/%.coffee
	$(COFFEE) $(COFFEE_FLAGS) -o $@ $<
