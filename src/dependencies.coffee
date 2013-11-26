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
SemanticError = (@mssg, @node, @name = 'SemanticError') ->

module.exports =
  
  # If given this dependency then the said node has a symbolTable field
  # which shall be used to verify scope queries
  symbolTable: ->
    constructTable = (tbl) ->
      @symbolTable = new SymbolTable(tbl)
    switch @className
      when 'Program' then (@posts ?= []).unshift constructTable
      else (@checks ?= []).unshift constructTable

  # Valid semantic check for entire program
  validSemantics: ->
    (@posts ?= []).push ->
      @children.statement?.verify?(@symbolTable)

  # Calls verify on it's children
  # NB - This function is high priority, must be at front of checks
  childVerification: (children...) ->
    (@checks ?= []).unshift (tbl) ->
      @children[child]?.verify(tbl) for child in children

  # Takes all potential lhs types, finished with the return type
  # Ex params - int, bool, bool
  typeRestriction: (childTypes...) ->
    (@checks ?= []).push (tbl) ->
      ctype = (c.type?(tbl) for own k,c of @children).reduce (a,b) ->
        (a if (b ?= a) == a)
      for t in childTypes
        return true if t == ctype

  # Takes the return type
  returnType: (rtype) ->
    # Set this node type to return the rtype (axiom)
    @type = -> rtype

  # Determines the return type for a unary
  unaryReturn: ->
    @type = (tbl) ->
      basic = {
        NegOp: 'int'
        LenOp: 'int'
        ToIntOp: 'int'
        OrdOp: 'char'
        NotOp: 'bool'
      }[@className]

  # Ident scoping check
  scopingVerification: ->
    @type = (tbl) ->
      type = tbl.verify @
      @type = -> type

  # Verifies that all children have the same type
  typeEquality: (fields...) ->
    @type = (tbl) ->
      eq = (@children[k].type?(tbl) for k in fields).reduce (t1,t2) ->
        if t2 == t2 then t2 else null
      if not eq
        throw new SemanticError 'Type equality failed', @

  # Configures function app and decl
  functionParams: ->
    switch @className
      when 'FunctionDeclaration' then null
      when 'FunctionApplication' then null


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

