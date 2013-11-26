###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112 amv12 skd212 ot612
# File: nodeHelpers.coffee
# Desc: Contains helpers for the pegjs node creation
###############################################################################

module?.exports =
  constructLiteral : (Nodes, key, value) ->
    LiteralLookup =
      ident:  Nodes.ident
      int:    Nodes.IntLiteral
      bool:   Nodes.BoolLiteral
      char:   Nodes.CharLiteral
      string: Nodes.StringLiteral
      array:  Nodes.ArrayLiteral
      pair:   Nodes.PairLiteral
    
    new LiteralLookup[key]  value

  
  constructStatement : (Nodes, key, values...) ->
    statementLookup =
      skip:           Nodes.Skip
      read:           Nodes.Read
      free:           Nodes.Free
      return:         Nodes.Return
      exit:           Nodes.Exit
      print:          Nodes.Print
      println:        Nodes.Println
      Declaration:    Nodes.Declaration
      NonDeclaration: Nodes.NonDeclaration
  
    new statementLookup[key] values...

  
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

  constructLookup : (Nodes, key, ident, index) ->
    lookupLookup = 
      array: Nodes.ArrayLookup
      pair:  Nodes.PairLookup

    new lookupLookup[key] ident, index

