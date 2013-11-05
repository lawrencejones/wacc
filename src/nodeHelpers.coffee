###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112 amv12 skd212 ot612
# File: nodeHelpers.coffee
# Desc: Contains helpers for the pegjs node creation
###############################################################################

module?.exports =
  constructLiteral : (Nodes, key, value) ->
    literalLookup =
      string: Nodes.StringLiteral
      char:   Nodes.CharLiteral
      int:    Nodes.IntLiteral
      bool:   Nodes.BoolLiteral
      array:  Nodes.ArrayLiteral
      pair:   Nodes.PairLiteral
    
    new literalLookup[key]  value
  
  constructStatement : (Nodes, key, value) ->
    statementLookup =
      skip:    Nodes.Skip
      print:   Nodes.Print
      println: Nodes.Println
      read:    Nodes.Read
      free:    Nodes.Free
      return:  Nodes.Return
      exit:    Nodes.Exit
  
    new statementLookup[key] value
  
  constructUnary : (Nodes, key, value) ->
    unaryLookup =
      '!':     Nodes.NotOp
      '-':     Nodes.NegOp
      'len':   Nodes.LenOp
      'ord':   Nodes.OrdOp
      'toInt': Nodes.ToIntOp
  
    new unaryLookup[key] value
  
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
