# Sample Makefile for the WACC Compiler lab: edit this to build your own comiler
# Locations

SOURCE_DIR	:= src
OUTPUT_DIR	:= bin 

# Unix tools

FIND	:= find
RM	:= rm -rf
MKDIR	:= mkdir -p

# Java tools

JAVA	:= java
JAVAC	:= javac

JFLAGS		:= -sourcepath $(SOURCE_DIR) -d $(OUTPUT_DIR) -cp lib/antlr-4.1-complete.jar 
JVMFLAGS	:= -ea

# the rules

all: rules

rules: 
	$(FIND) $(SOURCE_DIR) -name '*.java' > $@
	$(MKDIR) $(OUTPUT_DIR)
	$(JAVAC) $(JFLAGS) @$@
	$(RM) rules

clean:
	$(RM) rules $(OUTPUT_DIR)


