###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112 amv12 skd212 ot612
# File: nodeHelpers.coffee
# Desc: Contains helpers for the pegjs node creation
###############################################################################

# Helper to construct literal nodes
# Takes a key (for the node type) a stack object where
# the last item is guaranteed to be the previous object
# and a value to assign.
# Call in scope of Nodes
constructLiteral = (key, value, stack) ->
  literalLookup =
    string: StringLiteral
    char:   CharLiteral
    int:    IntLiteral
    bool:   BoolLiteral
    array:  ArrayLiteral
  
  new literalLookup(key) stack.peek(), value


