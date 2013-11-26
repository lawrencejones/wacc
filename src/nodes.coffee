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

path = require 'path'
dependencies = require (path.join __dirname, 'dependencies')
BaseNode = require (path.join __dirname, 'baseNode')
module.exports ?= {}

# Function to start node creation
createNodes = (template, Parent = BaseNode) ->
  # For the className and the following specs of the child
  for own className,specs of template
    # Match against specs
    [ps, ds, subclasses] = specs ? [[]]
    # If just a list of deps then switch ps and ds
    if specs.length is 1
      ds = ps
      ps = []

    # Generate next child
    class Child extends Parent
      className: className
      paramKeys: ps.concat Parent::paramKeys ? []
      depKeys: ds.concat Parent::depKeys ? []

    # _CATEGORY_
    # UnaryOps: [ [params], [deps], {subclasses} ]
    if specs.length is 1
      return createNodes subclasses, Child
    # _INLINED_
    # FunctionApplication: [ [params], [deps] ]
    # _TERMINAL_
    # LenOp: [ [deps] ]
    else
      [ Child::depKeys,
        Child::paramKeys ].map (a) -> a.sort()
      module.exports[className] = Child

  return module.exports


# Function call to create nodes, initialises the node structure
createNodes
  UnaryOps: [
    ['rhs'], ['unaryReturn']
    # TODO - Determine efficient method
    NegOp: null        # int  -> int
    OrdOp: null        # int  -> char
    LenOp: null        # str  -> int
    ToIntOp: null      # char -> int
    NotOp: null        # bool -> bool
  ]

  BinOps: [
    ['lhs', 'rhs'], []
    ArithmeticOps: [  # int -> int -> int
      [], ['typeRestriction(int)', 'returnType(int)']
      MulOp: null     # int -> int -> int 
      AddOp: null     # int -> int -> int
      SubOp: null     # int -> int -> int
      DivZeroOps: [
        [], []
        DivOp: null   # int -> int -> int
        ModOp: null   # int -> int -> int
      ]
      ComparisonOps: [
        [], ['returnType(bool)']
        LessOp: null       # int  -> int  -> bool
        LessEqOp: null     # int  -> int  -> bool 
        GreaterOp: null    # int  -> int  -> bool
        GreaterEqOp: null  # int  -> int  -> bool
      ]
    ]
    LogicalOps: [
      [], ['typeRestriction(bool)', 'returnType(bool)']
      AndOp: null        # bool -> bool -> bool
      OrOp: null         # bool -> bool -> bool
    ]
    EqualityOps: [
      [], ['typeRestriction(int,bool)', 'returnType(bool)']
      EqOp: null         # int|bool -> int|bool -> bool
      NotEqOp: null      # int|bool -> int|bool -> bool
    ]
    AssignmentOps: [
      [], ['typeEquality']
      Declaration: null  # { left: Ident,     right: AssignRhs }
      Assignment: null   # { left: AssignLhs, right: AssignRhs }
    ]
  ]

  Statements: [
    ['rhs'], []
    Skip: null     # NA
    Return: null   # any
    Read: null     # any
    Exit: null     # any
    Print: null    # any
    Println: null  # any
    Free: [['typeRestriction(pair)']]  # pair
  ]

  Functions: [
    ['ident'], ['functionParams']
    FunctionDeclaration: [
      ['paramList', 'rtype', 'statement'], ['symbolTable']
    ]
    FunctionApplication: [['args'], []]
  ]


  Scopes: [
    ['statement'], []
    Scope: null
    Programs: [
      ['functionDefs'], ['validSemantics']
      Program: null
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
    PairRhss: [
      ['value1', 'value2'], []
      PairRhs: null
    ]
  ]
  

