###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: module.coffee
# Desc: Collects the separate components of the compiler together, to export
#       as a single wacc object that will contain all functions, data etc.
###############################################################################

[syntaxParser, errorFormatter] = require './syntax'
nodes = require './nodes'

Wacc =

  Parser: syntaxParser
  ErrorFormatter: errorFormatter
  SemanticAnalyser: null
  CodeGenerator: null
  Optimiser: null
  Compiler: null
  Nodes: nodes
  
  # Can throw a syntax error
  parse: (src, options) ->
    options['verbose'] ?= true
    @Parser(
      src
      options['verbose']
      options['filename']
      options['returnMessage']
    )

  formatError: (err, src, options) ->
    errorFormatter(
      err, src
      options['filename']
    )

  analyse: (ast, options) ->

  generateCode: (ast, options) ->

  optimiseCode: (code, options) ->

  generateMachine: (code, options) ->


# Export the Wacc object
module.exports = Wacc
