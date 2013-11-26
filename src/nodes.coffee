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

# Represents the base node
class BaseNode
  constructor: (params...) ->
    @className = this.constructor.className
    for d in @deps
      [key, params...] = d.split /[(),]/g
      dependencies[key]?.call?(this, params...)
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

# Function to start node creation
createNodes = (template, Parent = BaseNode) ->

  # For the className and the following specs of the child
  for own className,specs of template
    # Create new class for our child node
    Child = class extends Parent
      @className = className
    # If a category
    if specs.length > 1
      [ps, deps, subclasses] = specs
      [Child::params, Child::deps] = [ps, deps]
      createNodes subclasses, Child
    # If a final node
    else
      Child::deps = specs?[0] ? []
      module.exports[className] = Child

  return module.exports


# Function call to create nodes, initialises the node structure
createNodes
  UnaryOps: [
    ['rhs'], []
    NegOp: null        # int  -> int
    LenOp: null        # str  -> int
    ToIntOp: null      # char -> int
    OrdOp: null        # int  -> char
    NotOp: null        # bool -> bool
  ]
  BinOps: [
    ['lhs', 'rhs'], []
    MulOp: null        # int  -> int  -> int
    AddOp: null        # int  -> int  -> int
    SubOp: null        # int  -> int  -> int
    DivOp: null        # int  -> int  -> int
    ModOp: null        # int  -> int  -> int
    LessOp: null       # int  -> int  -> bool
    LessEqOp: null     # int  -> int  -> bool 
    GreaterOp: null    # int  -> int  -> bool
    GreaterEqOp: null  # int  -> int  -> bool
    AndOp: null        # bool -> bool -> bool
    OrOp: null         # bool -> bool -> bool
    EqOp: null         # int|bool -> int|bool -> bool
    NotEqOp: null      # int|bool -> int|bool -> bool
  ]

  Statements: [
    ['right'], ['rhsDeclaredInTable']
    ChecksNeeded: [ 
      [], ['typeCheck']
      Read: null #can only be either a program variable, an array elem or a pair elem
      Free: null #must be given expression of type pair
      Return: null
    ]
    Skip: null
    Exit: null #takes an expression
    Print: null   #prints can be given any type...
    Println: null #...............................
    Assignment: [
      ['left'], ['typeEquality']
      Declaration: null #add in table and check type equality
      NonDeclaration:[['lhsDeclaredInTable']] #check in table and type equality and then update it in table
    ]
  ]

  FunctionApplications: [
    ['ident', 'paramList'], ['validParams']
    FunctionApplication: null #check function exists and params match
    #check return type against function return type
  ]

  Scopes: [
    ['body'], ['symbolTable']
    Scope: null
    Programs: [
      ['functionDefs'], ['validSemantics']
      Program: null
    ]
    Functions: [
      ['ident', 'returnType', 'paramList'], []
      Function: null
    ]
    FlowConstructs: [
      ['condition'], ['validCondition']
      While: null #int|bool -> int|bool -> bool
      Conditionals: [
        ['elseBody'], []
        Conditional: null
      ]
    ]
  ]

  Lookups: [
    ['ident', 'index', 'length'], []
    ArrayLookup: [['checkInBounds']] #check array exists index has to be int
    PairLookup: null #check exists 
  ]

  Terminals: [
    ['type', 'value'], []
    Ident: null
    IntLiteral: null
    BoolLiteral: null
    CharLiteral: null
    StringLiteral: null
    ArrayLiteral: null
  ]

  Pairs: [
    [], []
    PairTypes: [
      ['type1', 'type2'], [] 
      PairType: null
    ]
    PairRhsd: [
      ['value1', 'value2'] []
      PairRhs: null
    ]
  ]
  

