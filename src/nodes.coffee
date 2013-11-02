###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: nodes.coffee
# Desc: Defines the structure of each node along with a create node
#       function that uses the given structure and pegjs matched data
#       to generate a node object for the symbol table.
###############################################################################

Nodes =
  BinOps: [
    AssignOps: [
      AssignEqOp: null
    ]
    ArithmeticOps: [
      MulOp: null
      DivOp: null
      ModOp: null
      AddOp: null
      SubOp: null
    ]
    ComparisonOps: [
      LessOp: null
      LessEqOp: null
      GreaterOp: null
      GreaterEqOp: null
    ]
  ]

  UnaryOps: [
    SignOps: [
      NegOp: null
    ]
    BuiltinOps: [
      LenOp: null
      OrdOp: null
      ToIntOp: null
    ]
    NotOp: null
  ]

  Statements: [
    Skip: null
    Print: null
    Println: null
    Read: null
    Free: null
    Return: null
    Exit: null
  ]

  FunctionApplications: [
  ]

  Program: [
  ]

  Conditional: null

  While: null

  For: null

