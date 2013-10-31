###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: module.coffee
# Desc: Collects the separate components of the compiler together, to export
#       as a single wacc object that will contain all functions, data etc.
###############################################################################

syntaxParser = require './syntax'
nodes = require './nodes'

Wacc =

  Parser: syntaxParser
  SemanticAnalyser: null
  CodeGenerator: null
  Optimiser: null
  Compiler: null
  Nodes: nodes
  
  # Can throw a syntax error
  parse: (src, filename) ->
    @Parser(src, filename)

  analyse: (ast, options) ->

  generateCode: (ast, options) ->

  optimiseCode: (code, options) ->

  generateMachine: (code, options) ->


# Export the Wacc object
module.exports = Wacc
