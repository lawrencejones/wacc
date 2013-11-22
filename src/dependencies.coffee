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
    
  # If given this dependency then the said node has a symbolTable field
  # which shall be used to verify scope queries
  symbolTable: ->
    @symbolTable = new SymbolTable(@)

  # Initiates verification of the two/one leaf/es
  childVerification: ->
    (@checks ?= []).push (tbl) ->
      @left?.verify?(tbl)
      @right?.verify?(tbl)

  # Means nodes are required to register or verify themselves against
  # the symbol table, and any type questions will need to be referenced
  symbolTableVerification: ->
    @type = (tbl) ->
      @btype ?= tbl.verify this
      return @btype

  typeEquality: ->
    (@checks ?= []).push (tbl) ->
      if not (@left? and @right?)
        throw new Error 'Missing operands'
      if @left?.type(tbl) != @right?.type(tbl)
        console.log @left.type(tbl)(tbl)
        console.log "Mismatched types #{@left.type(tbl)}/#{@right.type(tbl)}"
        

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




