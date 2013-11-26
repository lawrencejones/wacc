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
  
  #TOD  # Takes all potential lhs types, finished with the return type
  # Ex params - int, bool, bool
  typeResolution: (childTypes...) ->
    (@checks ?= []).push (tbl) ->
      ltype = (c?.type?(tbl) for c in [@rhs, @lhs]).reduce (a,b) ->
        (a if (b ?= a) == a)
      for t in lhsTypes
        return true if t is ltype

  # Takes the return type
  returnType: (rtype) ->
    # Set this node type to return the rtype (axiom)
    @type = -> rtype

  
  #TODO:...... check rhs is in the symbol table
  rhsDeclaredInTable: ->

  #TODO:...... same as for rhs above
  lhsDeclaredInTable: ->

  #TODO:.....for assigning, need to check boths lhs and rhs have
  #the same type
  typeEquality: ->

  #TODO:.....check that the params are valid
  validParams: ->

  #TODO:..... for anything that introduces scope, creates a new symbol table
  symbolTable: ->

  #TODO:.....check valid semantics for the program
  validSemantics: ->

  #TODO:....check valid condition for loops
  validCondition: ->

  #TODO:..... check the array access is in bounds
  checkInBounds: ->
    
  # If given this dependency then the said node has a symbolTable field
  # which shall be used to verify scope queries
  symbolTable: ->
    @symbolTable = new SymbolTable(@)

  # Initiates verification of the two/one leaf/es
  childVerification: ->
    (@checks ?= []).push (tbl) ->
      @lhs?.verify?(tbl)
      @rhs?.verify?(tbl)

  # Means nodes are required to register or verify themselves against
  # the symbol table, and any type questions will need to be referenced
  symbolTableVerification: ->
    @type = (tbl) ->
      @btype ?= tbl.verify this
      return @btype

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

  # Valid semantic check for entire program
  validSemantics: ->
    (@posts ?= []).push ->
      @statement?.verify?(@symbolTable)




