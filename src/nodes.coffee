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

  The createNodes function will traverse this object and produce a Class
  for each of the possible terminals/productions. Ideally, an abstract
  syntax tree that represents a wacc program will be produced using
  instances of the below classes.

  Any pluralised keys represent a category of nodes. Each key value pair
  is made of a class name and an array, inside which is stored...
    
    Category: [
      [ leaves... ]
      __subCategories__ : Category...
      __terminals__ : null
    ]

  The first element in the array (leaves) holds the labels for use in
  storing all terminal operands. For example, Binary operations that
  are infix will take be represented by {A (Op) B}, and so label names
  'left' and 'right' shall be used to reference A and B respectively.
  These labels will be used to produce error messages and to access
  the attached terminals once inside the tree.

  Creating the nodes is simply a process of traversing the tree and
  recursively calling to allow for each class to have it's prototype
  assigned to the owning key class. This means that all nodes inherit
  the properties of their owning class and therefore should align
  semantic interests against it's respective labels.
###

Nodes =

  # All infix operations
  BinOps: [
    ['left', 'right']
    AssignOps: [
      ['assignee', 'value']
      AssignEqOp: null
    ]
    ArithmeticOps: [
      MulOp: null
      DivOp: null
      ModOp: null
      AddOp: null
      SubOp: null
    ]
    ComparisonOps: [
      LessOp: null
      LessEqOp: null
      GreaterOp: null
      GreaterEqOp: null
    ]
  ]

  UnaryOps: [
    SignOps: [
      NegOp: null
    ]
    BuiltinOps: [
      LenOp: null
      OrdOp: null
      ToIntOp: null
    ]
    NotOp: null
  ]

  Statements: [
    Skip: null
    Print: null
    Println: null
    Read: null
    Free: null
    Return: null
    Exit: null
  ]

  FunctionApplications: [
  ]

  Program: [
  ]

  Conditional: null

  While: null

  For: null

