###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112 amv12 skd212 ot612
# File: nodes.coffee
# Desc: See below.
###############################################################################

###
  The object below on which createNodes is called contains information
  on how to create the classes for each possible node in the wacc language.

  The createNodes function will traverse this object and produce an object
  for each of the possible terminals/productions. Ideally, an abstract
  syntax tree that represents a wacc program will be produced using
  objects that inherit from the below structure.

  Any pluralised keys represent a category of nodes. Each key value pair
  is made of a class name and an array, inside which is stored...
    
    Category: [
      [ objProperties... ]
      [ dependencies... ]
      nestedCategories : Category...
      finalPrototype : [ [ extraPredicates... ] ]
    ]

  Within a category, the first array shall contain a list of strings
  which will be properties of all finalPrototypes within this category
  or nested categories.

  The second array within a category shall contain a list of strings
  that represent the functions to call on finalising the construction
  of a node. These will modify the class to include appropriate
  functionality.

  A final prototype is denoted by a name (singular) and a null value
  or an array. The array will represent any supplementary predicates
  to be run on finishing construction of that specific node.
###

dependencies = require (require 'path').join(__dirname, 'dependencies')
module.exports ?= {}

createNodes = (template, parent = (@params = [], @deps = []) ->) ->

  # For the className and the following specs of the child
  for own className,specs of template
    specs ?= [[]]
    obj = class extends parent
      @className: className
      constructor: (params...) ->
        @className = this.constructor.className
        dependencies[f]?.call?(this) for f in @deps
        @type ?= (tbl) ->
          @btype or @left?.type?(tbl) or 'UNKNOWN'
        this.populate(params...) if params?
        this
      populate: ->
        for k, i in @params
          this[k] = arguments[i]
          this[k].parent = @ if this[k]?.className?
        f.call?(this) for f in @posts ? []
        this
      verify: (tbl) ->
        @checks.pop().call?(this, tbl) while @checks?[0]?

    # If a category
    if specs.length > 1
      [ps, deps, subclasses] = specs
      obj::params = (obj?.__super__?.params ? []).concat ps
      obj::deps = (obj?.__super__?.deps ? []).concat deps
      createNodes subclasses, obj
    # If a final node
    else
      obj::deps = (obj?.__super__?.deps ? []).concat specs[0]
      module.exports[className] = obj

  return module.exports

# Function call to create nodes, initialises the node structure
createNodes
  # All infix operations
  BinOps: [
    ['left', 'right'] # Parameters that all in BinOps include
    ['childVerification'] # Post condition checks
    AssignOps: [
      [], ['typeEquality']
      AssignEqOp: null
    ]
    ArithmeticOps: [
      [], []
      DivZeroRisks: [
        [], []
        DivOp: null
        ModOp: null
      ]
      MulOp: null
      AddOp: null
      SubOp: null
    ]
    BooleanOps: [
      [], []
      AndOp: null
      OrOp: null
    ]
    ComparisonOps: [
      [], []
      EqOp: null
      NotEqOp: null
      NumericComparisons: [
        [], []
        LessOp: null
        LessEqOp: null
        GreaterOp: null
        GreaterEqOp: null
      ]
    ]
    Statement: null
    Expression: null
  ]

  UnaryOps: [
    ['operand'], ['childVerification']
    SignOps: [
      [], ['onlyInts']
      NegOp: null
    ]
    BuiltinOps: [
      [], []
      LenOp: null
      OrdOp: null
      ToIntOp: null
    ]
    NotOp: null
  ]

  Statements: [
    ['operand'], []
    Skip: null
    Print: null
    Println: null
    Read: [['onlyString']]
    Free: null
    Return: null
    PairAccessor: null
    Exit: null
  ]

  FunctionApplications: [
    ['label', 'params'], ['validParams']
    FunctionApplication: null
  ]

  Scopes: [
    ['body', 'symbolTable'], ['symbolTable']
    Scope: null
    Functions: [
      ['ident', 'returnType', 'paramList'], []
      Function: null
    ]
    Programs: [
      ['functionDefs'], ['validSemantics']
      Program: null
    ]
    FlowConstructs: [
      ['condition'], ['validCondition']
      Conditionals: [
        ['elseBody'], []
        Conditional: null
      ]
      While: null
    ]
  ]

  Symbols: [
    ['label'], ['symbolTableVerification']
    Ident: null
    TypedSymbols: [
      ['btype'], []
      Declaration: null
      Param: null
    ]
  ]

  # TODO - Implement pairs
  Literals: [
    ['value'], ['literalType']
    StringLiteral: null
    IntLiteral: null
    BoolLiteral: null
    CharLiteral: null
    PairLiteral: null
  ]

  DepthLiterals: [
    ['dimension'], []
    ArrayElem: [['validAccess']]
    ArrayLiteral: [['homogenousTypes']]
  ]

