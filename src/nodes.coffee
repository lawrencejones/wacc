###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
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
      [ postConstructionPredicate... ]
      nestedCategories : Category...
      finalPrototype : [ extraPredicates... ]
    ]

  Within a category, the first array shall contain a list of strings
  which will be properties of all finalPrototypes within this category
  or nested categories.

  The second array within a category shall contain a list of strings
  that represent the functions to call on finalising the construction
  of a node. These will raise semantic errors if any issues are found.

  A final prototype is denoted by a name (singular) and a null value
  or an array. The array will represent any supplementary predicates
  to be run on finishing construction of that specific node.
###

Nodes =

    # All infix operations
    BinOps: [
      ['left', 'right'] # Parameters that all in BinOps include
      [] # Post condition checks
      AssignOps: [
        ['@assignee','@value'], ['typeEquality']
        AssignEqOp: null
      ]
      ArithmeticOps: [
        [], ['noOverflow', 'onlyInts']
        DivZeroRisks: [
          [], ['noDivZero']
          DivOp: null
          ModOp: null
        ]
        MulOp: null
        AddOp: null
        SubOp: null
      ]
      ComparisonOps: [
        [], ['onlyInts']
        LessOp: null
        LessEqOp: null
        GreaterOp: null
        GreaterEqOp: null
      ]
    ]
  
    UnaryOps: [
      ['operand'], []
      SignOps: [
        [], ['onlyInts']
        NegOp: null
      ]
      BuiltinOps: [
        [], []
        LenOp: ['onlyArrays']
        OrdOp: ['onlyInts']
        ToIntOp: ['onlyChars']
      ]
      NotOp: ['onlyBools']
    ]
  
    Statements: [
      ['operand'], []
      Skip: null
      Print: null
      Println: null
      Read: ['onlyString']
      Free: null
      Return: null
      Exit: null
    ]
  
    FunctionApplications: [
      ['label', 'params'], ['validParams']
      FunctionApplication: null
    ]
  
    Scopes: [
      ['symbolTable'], []
      Programs: [
        ['functions', 'statement'], []
        Program: null
      ]
      FlowConstructs: [
        ['condition', 'body'], ['validCondition']
        Conditional: null
        While: null
      ]
    ]

    Symbols: [
      ['label', 'value'], ['validScope']
    ]

    # TODO - Implement pairs
    Literals: [
      ['value'], []
      StringLiteral: null
      IntLiteral: null
      BoolLiteral: null
      CharLiteral: null
      ArrayElem: null
    ]
    
