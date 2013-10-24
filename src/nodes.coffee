###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: nodes.coffee
# Desc: Defines the structure of each node along with a create node
#       function that uses the given structure and pegjs matched data
#       to generate a node object for the symbol table.
###############################################################################

Nodes : [
  BinOps: [
    AssignOp: [
      ['assignee', 'expr']
    ]
  ]
  UnaryOps: [
  ]
  Statements: [
  ]
  FunctionApplications: [
  ]
  Program: [
  ]
  Conditional: [
  ]
  While: [
  ]
  For: [
  ]
]
