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

  # Assign for the prototype base
  depKeys: []; paramKeys: []
  # Shared constructor for all nodes
  # Takes children - an object that gives values for all children
  #   eg. { lhs: <value>, rhs: <value> }
  constructor: (arg) ->
    # Initialise keys for children
    (@children ?= {})[k] = null for k in @paramKeys
    # For all dependency keys in @depKeys (proto)
    for d in @depKeys
      # Match on the dep key and params
      [key, params...] = d.split /[(),]/g
      # Call the dependencies
      dependencies[key]?.call?(this, params...)
    # Populate the children
    this.populate(arg) if arg?
    this

  # Populates the children
  # Takes an array of arguments, either...
  #   [ {params_map} ]
  # Or
  #   value, value, value, ...
  # Corresponding to param1, param2,etc
  # POST - Must ensure all arguments are given
  populateWithArgs: (args...) ->
    # Copy into a hash
    res = {}
    populate (res[k] = args[i] for k,i in @paramKeys[0..(@args.length)])
  populate: (children) ->
    # If not an object then throw error
    if typeof children is not 'object'
      throw new Error "Populate expected param hash: #{children}"

    # TODO - Catch error
    #--* Now the children variable is an object
    for own k,v of children
      # If the key is in param keys then assign
      @children[k] = v if @paramKeys.indexOf(k) != -1
      
    # Verify that the params are all filled
    for k in @paramKeys
      # Else throw error
      if not @children[k]?
        throw new Error 'Populate did not receive all args.'

    # For all our post checks, run them
    f.call?(this) for f in @posts ? []
    this

  # Default type answer
  type: ->
    btype or @left?.type?(tbl) or 'UNKNOWN'

  # Final node verifications
  verify: (tbl) ->
    @checks.pop().call?(this, tbl) while @checks?[0]?
    

# Function to start node creation
createNodes = (template, Parent = BaseNode) ->

  # For the className and the following specs of the child
  for own className,specs of template
    specs ?= [[]]
    # Create new class for our child node
    Child = class extends Parent
      className: className
    # If a category
    if specs.length > 1
      [ps, deps, subclasses] = specs
      Child::paramKeys = ps.concat Parent::paramKeys ? []
      Child::depKeys = deps.concat Parent::depKeys ? []
      createNodes subclasses, Child
    # If a final node
    else
      Child::depKeys = Parent::depKeys.concat specs[0] ? []
      [ Child::depKeys,
        Child::paramKeys ].map (a) -> a.sort()
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
      Read: null
      Free: null
      Return: null
    ]
    Skip: null
    Exit: null
    Print: null
    Println: null
    Assignment: [
      ['left'], ['typeEquality']
      Declaration: null
      NonDeclaration:[['lhsDeclaredInTable']]
    ]
  ]

  FunctionApplications: [
    ['ident', 'paramList'], ['validParams']
    FunctionApplication: null
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
      While: null
      Conditionals: [
        ['elseBody'], []
        Conditional: null
      ]
    ]
  ]

  Lookups: [
    ['ident', 'index'], []
    ArrayLookup: [['checkInBounds']]
    PairLookup: null
  ]

  Terminals: [
    ['type', 'value'], []
    Ident: null
    IntLiteral: null
    NoolLiteral: null
    CharLiteral: null
    StringLiteral: null
    ArrayLiteral: null
    Pair: [
      ['secondType', 'secondValue'], []
      PairLiteral: null
    ]
  ]

