###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: cli.coffee
# Desc: The entry point for the wacc command line interface. Determines
#       what functions to call, compilation or parse tree generation, etc.
###############################################################################

fs = require 'fs'

# List of command line options for wacc
optAliases = {
  p: '--parse-only'
  s: '--semantic-check'
  t: '--print-tree'
  a: '--assembly'
  e: '--eval'
  r: '--recursive'
}

# Generate simple array of legal options
legalOptions = [].concat (["-#{k}",v] for own k,v of optAliases)...
# Loop back aliases
optAliases[v] = v for k,v of optAliases
console.log optAliases
# Set up max and min number of targets after options
targetMin = targetMax = 1

# Split argv into valid invalid and targets
argv = process.argv[2..]
[valid, invalid, targets] = argv.reduce ((v,c) ->
  v[+(legalOptions.indexOf(c) == -1) + +(not /\-.+/.test(c))].push c; v), [[],[],[]]


# Verify no invalid flags
if invalid.length > 0
  console.error "Invalid flags: #{invalid.join ', '}"
  process.exit 1

# Verify that target source files have been supplied
if not targetMin < targets.length < targetMax
  switch targets.length
    when 0 then console.error \
      'Please supply source file'
    else console.error \
      'Too many source files'
  process.exit 1

# Verify that the target files exist
for t in targets
  if not fs.existsSync(t)
    console.error "Error reading file '#{t}'"
    process.exit 1

# Process flags into their correct switches
options = {}
options[optAliases[f]] = true for f in valid
console.log options

###############################################################################
# Define Compiler Steps
###############################################################################

# Supplied as callback to file read function
run = (err, filename, src, options) ->

  # Parsing, returns abstract syntax tree
  parse = (src) ->
    # Parse the given source
    tree = wacc.parse(src)
    checkSemantics(tree, 'Semantic Analysis')

  # Check semantics
  checkSemantics = \
    unsupported || (tree) ->
      return if options['--parse-only']
      # TODO - Implement semantic analysis
      generateCode(tree, 'Code Generation')

  # Assembly code generation
  generateCode = \
    unsupported || (tree) ->
      return if options['--semantic-check']
      # TODO - Implement code generation
      optimiseCode(null, 'Code Optimisation')

  # Optimise the code
  optimiseCode = \
    unsupported || (code) ->
      # TODO - Implement code optimisations
      code = optimiseCode(code) unless options['--no-optimisation']
      generateMachine(code, 'Generate Machine Code')
  
  # Compilation
  generateMachine = \
    unsupported || (code) ->
      return if options['--assembly']
      # TODO - Implement machine code generation
      executeBinary(filename, 'Code Execution')

  # Execution
  executeBinary = \
    unsupported || (filename) ->
      return unless options['--eval']
      # TODO - Implement binary execution
      console.log "Finished executing file '#{filename}'"

  # Unsupported feature
  unsupported = (dump, feature) ->
    # Note to console that this is unsupported
    console.error \
      "Unsupported feature '#{feature}'"
    console.log dump if options['--verbose']

# Begin loading files
targets.map (t) ->
  fs.readFile(t, 'utf8', (err, src) -> run(err, t, src, options))

