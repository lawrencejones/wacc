###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: cli.coffee
# Desc: The entry point for the wacc command line interface. Determines
#       what functions to call, compilation or parse tree generation, etc.
###############################################################################

# List of command line options for wacc
optAliases = {
  p: '--parse-only'
  s: '--semantic-check'
  t: '--print-tree'
  a: '--assembly'
  e: '--eval'
  r: '--recursive'
}

# Generate simple array of legal options
legalOptions = [].concat ([k,v] for own k,v of optAliases)...





