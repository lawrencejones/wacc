###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: _entry.coffee
# Desc: The entry point for the wacc testsuite.
# TODO: Build for asynchronous if have time
###############################################################################

fs = require 'fs'
wacc = require '../lib/module'

results = {
  syntax:
    valid: {}
    invalid: {}
  semantic:
    valid: {}
    invalid: {}
}

# Hold number of request to run callback
count = 0

# Takes a directory from **within** the examples folder
testFiles = (dir, test, res, cb) ->
 
  # Allows recursive testing of sub directories
  recurseTest = (tc, lvl) ->
    count++
    fs.stat tc, (err, stat) =>
      count--
      padding = (new Array(2*lvl)).join(' ')
      handle = tc.split('/')[-1..].pop()
      if stat.isDirectory()
        recurseTest "#{tc}/#{f}", (lvl + 1) for f in fs.readdirSync tc
      else
        [others..., category, key] = tc.split('/')
        if not /.+\.wacc$/.test key
          return
        res[category] ?= {}
        res[category][key] = test(tc)
        cb() if cb and count == 0

  try
    # For each file in the folder, recurse test
    for f in (fs.readdirSync (dir = "examples/#{dir}"))
      recurseTest "#{dir}/#{f}", 1
  catch err
    # If errored the the folder config is incorrect
    # Expecting __root__/examples/(valid|invalid)
    console.error 'Missing examples folder.'
    process.exit 1


# Checks for valid syntax, returns null if the syntax does not
# throw a syntax error, the error message if it does.
validSyntax = (file) ->
  try
    src = fs.readFileSync(file, 'utf-8')
    wacc.parse src, {
      verbose: false
      filename: file
      returnMessage: true
    }
  catch err
    return wacc.formatError(err, src, {filename: file})
  return null

# Checks for invalid syntax. If the parsing does not raise an error
# then will return false, else true. Makes a non null entry into
# errors.syntax.invalid under the filename if doesn't detect error.
invalidSyntax = (file) ->
  try
    src = fs.readFileSync(file, 'utf-8')
    wacc.parse src, {
      verbose: false
      returnMessage: false
    }
  catch err
    return true
  return false

# Prints the formatted test results
printResults = ->
  console.log "\nTesting syntax on valid examples..."
  for own cat,tests of results.syntax.valid
    process.stdout.write "  Category '#{cat}'   "
    failed = []
    for own test,res of tests
      [col,clr] = [res and '\x1b[31m' or '\x1b[32m', '\x1b[0m']
      process.stdout.write "#{col}*#{clr}"
      failed.push res if res
    process.stdout.write '\n'
    if failed.length > 0
      console.log ('\n' + mssg) for mssg in failed
      console.log '\n'

testFiles 'valid', validSyntax, results.syntax.valid
testFiles 'invalid', invalidSyntax, results.syntax.invalid, printResults
