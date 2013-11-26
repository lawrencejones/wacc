###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112 amv12 skd212 ot612
# File: nodes.coffee
# Desc: Defines the basic node behaviour that every node will satisfy
###############################################################################

dependencies = require (require 'path').join __dirname, 'dependencies'

# Represents the base node
module?.exports = class BaseNode

  # Assign for the prototype base
  @className: 'BaseNode'
  dependencies: dependencies
  depKeys: []; paramKeys: []; checks: []
  # Shared constructor for all nodes
  # Takes children - an object that gives values for all children
  #   eg. { lhs: <value>, rhs: <value> }
  constructor: (arg) ->
    @className = @constructor.className
    @verified = false
    # For all dependency keys in @depKeys (proto)
    for d in @depKeys
      # Match on the dep key and params
      [key, params...] = d.split(/[(),]/g).filter (s) -> s != ''
      # Call the dependencies
      @dependencies[key]?.call(this, params...)
    # Initialise keys for children
    (@children ?= {})[k] = null for k in @paramKeys
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
      if @paramKeys.indexOf(k) != -1
        @children[k] = v
      else @[k] = v
      
    # For all our post checks, run them
    f.call?(this) for f in @posts ? []
    this

  # Default type answer
  type: -> @btype

  # Final node verifications
  verify: (tbl) ->
    console.log "Verifying #{@className} node"
    console.log tbl
    if not @verified
      c.call?(this, tbl) for c in @checks
      @verified = true
    

