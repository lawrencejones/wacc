###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112 amv12 skd212 ot612
# File: nodeHelpers.coffee
# Desc: Contains helpers for the pegjs node creation
###############################################################################

module?.exports =
  
  constructUnary : (Nodes, key, value) ->
    unaryLookup =
      '!':     Nodes.NotOp
      '-':     Nodes.NegOp
      'len':   Nodes.LenOp
      'ord':   Nodes.OrdOp
      'toInt': Nodes.ToIntOp
  
    new unaryLookup[key] value

  constructStatement : (Nodes, key, value) ->
    statementLookup =
      'println':  Nodes.Println
      'print':    Nodes.Print
      'free':     Nodes.Free
      'read':     Nodes.Read
      'exit':     Nodes.Exit
  
    new statementLookup[key] value
  
  constructBinary : (Nodes, key, first, second) ->
    binaryLookup =
      '*':   Nodes.MulOp
      '/':   Nodes.DivOp
      '%':   Nodes.ModOp
      '+':   Nodes.AddOp
      '-':   Nodes.SubOp
      '>=':  Nodes.GreaterEqOp
      '>':   Nodes.GreaterOp
      '<=':  Nodes.LessEqOp
      '<':   Nodes.LessOp
      '==':  Nodes.EqOp
      '!=':  Nodes.NotEqOp
      '&&':  Nodes.AndOp
      '||':  Nodes.OrOp
  
    new binaryLookup[key] first, second


