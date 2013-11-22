###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112 amv12 skd212 ot612
# File: symbolTable.coffee
# Desc: Exports an object that deals with global symbol table management.
###############################################################################

module?.exports = class SymbolTable

  # Constructs a symbol table class with a reference
  # to the node that it is attached to.
  constructor: (@owner) ->
    (@tbl = {}).__proto__ = @owner.symbolTable

  # Used to declare variable
  declareVar: (symbol, type) ->
    if @tbl.hasOwnProperty(symbol)
      throw new Error 'Already declared'
    else
      @tbl[symbol] = {type: type}

  # Verifies that the symbol table has an entry
  # Assuming it does, will return the type for the node
  # to use as it sees fit.
  useVar: () ->
    if not (s = @tbl[symbol])?
      throw new Error 'Variable not declared'
    else s.type

  # If not present in symbol table then add it
  # Else throw error
  declareFunction: (symbol, sig, type) ->
    if @tbl.hasOwnProperty(symbol)
      throw new Error 'Function already declared'
    else
      @tbl[symbol] = {sig: sig, type: type}




