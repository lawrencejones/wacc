###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: wacc.coffee
# Desc: Collects the separate components of the compiler together, to export
#       as a single wacc object that will contain all functions, data etc.
###############################################################################

[syntaxParser, errorFormatter] = require './syntax'
nodes = require './nodes'

module.exports =

  Parser: syntaxParser
  ErrorFormatter: errorFormatter
  CodeGenerator: null
  Optimiser: null
  Compiler: null
  Nodes: nodes
  
  # Can throw a syntax error
  parse: (src, options = {}) ->
    options['verbose'] ?= true
    @Parser src, options

  # TODO - evaluate if this is really necessary
  formatError: (err, src, options = {}) ->
    errorFormatter(
      err, src
      options['filename']
    )

  analyse: (ast, options) ->

  generateCode: (ast, options) ->

  optimiseCode: (code, options) ->

  generateMachine: (code, options) ->


