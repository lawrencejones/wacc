###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: dependencies.coffee
# Desc: A group of functions that are invoked to modify the node classes.
#       They can add event listeners and pre/post population hooks.
###############################################################################

path = require 'path'
SymbolTable = require path.join(__dirname, 'symbolTable')

module.exports =
  
  # Valid semantic check for entire program
  validSemantics: ->
    (@posts ?= []).push ->
      @statement?.verify?(@symbolTable)

  # Takes all potential lhs types, finished with the return type
  # Ex params - int, bool, bool
  typeRestriction: (childTypes...) ->
    (@checks ?= []).push (tbl) ->
      ctype = (c?.type?(tbl) for k,c of @children).reduce (a,b) ->
        (a if (b ?= a) == a)
      for t in childTypes
        return true if t == ctype

  # Takes the return type
  returnType: (rtype) ->
    # Set this node type to return the rtype (axiom)
    @type = -> rtype

  # Determines the return type for a unary
  unaryReturn: ->
    @type = -> {
      NegOp: 'int'
      LenOp: 'int'
      ToIntOp: 'int'
      OrdOp: 'char'
      NotOp: 'bool'
    }[@className]

  # Verifies that all children have the same type
  typeEquality: ->
    @type = ->
      eq = (k for own k,c of @children).reduce ((a, b) ->
        a.type() == b.type()), true
      if not eq then throw new Error 'Type equality failed'

  # Configures function app and decl
  functionParams: ->
    switch @className
      when 'FunctionDeclaration' then null
      when 'FunctionApplication' then null

  # If given this dependency then the said node has a symbolTable field
  # which shall be used to verify scope queries
  symbolTable: ->
    @symbolTable = new SymbolTable(@)

  # Initiates verification of the two/one leaf/es
  childVerification: ->
    (@checks ?= []).push (tbl) ->
      @lhs?.verify?(tbl)
      @rhs?.verify?(tbl)

  typeEquality: ->
    (@checks ?= []).push (tbl) ->
      if not (@lhs? and @rhs?)
        throw new Error 'Missing operands'
      if @lhs?.type(tbl) != @rhs?.type(tbl)
        console.log @lhs.type(tbl)(tbl)
        console.log "Mismatched types #{@lhs.type(tbl)}/#{@rhs.type(tbl)}"
        

  # Returns the basic type for literals
  literalType: ->
    @type = ->
      {
        StringLiteral: 'string'
        IntLiteral: 'int'
        BoolLiteral: 'bool'
        CharLiteral: 'char'
        PairLiteral: 'pair'
      }[@className]





