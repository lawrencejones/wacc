###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: _entry.coffee
# Desc: The entry point for the wacc testsuite.
# TODO: Build for asynchronous if have time
# TODO: Find more elegant solution to the globally scoped results
###############################################################################

fs = require 'fs'
exec = require('child_process').exec
path = require 'path'
wacc = require path.join(__dirname, '..', 'src', 'wacc')
notify = require path.join(__dirname, 'notify')

# Put results in global scope
results = {}
# Hold number of request to run callback
count = 0
# Hold number of failed tests
noOfFailed = 0

# Resets the test results
templateResults = ->
  syntax:
    valid: {}
    invalid: {}
  semantic:
    valid: {}
    invalid: {}


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
    }
  catch err
    if err?.name == 'SyntaxError'
      noOfFailed++
      return err.mssg
    else throw err
  return null


# Checks for invalid syntax. If the parsing does not raise an error
# then will return false, else will return the filename
invalidSyntax = (file) ->
  try
    src = fs.readFileSync(file, 'utf-8')
    wacc.parse src, {
      verbose: false
      returnMessage: false
    }
  catch err
    return false
  noOfFailed++
  return file


# Prints the formatted test results
printResults = ->

  # Given a block of results, will iterate through them and using
  # the supplied printFailed function, output appropriate error messages
  # Pre is the predicate for a failed test
  iterateTests = (block, pre, printFailed) ->
    for own cat,tests of block
      process.stdout.write "  Category '#{cat}'   "
      failed = []
      for own test,res of tests
        [col,clr] = [(pre res) and '\x1b[31m' or '\x1b[32m', '\x1b[0m']
        process.stdout.write "#{col}*#{clr}"
        failed.push res if (pre res)
      process.stdout.write '\n'
      printFailed(failed) if failed.length > 0
  
  # Valid syntax
  console.log "\nTesting syntax for valid examples..."
  iterateTests results.syntax.valid, ((t) -> t), (failed) ->
    console.log (('\n' + mssg) for mssg in failed).join '\n'

  # Invalid syntax
  console.log "\nTesting syntax for invalid examples..."
  iterateTests results.syntax.invalid, ((t) -> typeof(t) == 'string'), (failed) ->
    console.log '\x1b[31m'
    console.log "\n#{('      ' + f.split('/').pop() for f in failed).join('\n')}\n"
    console.log '\x1b[0m'


# Runs tests using the given wacc spec examples
# Returns number of failed test cases
testExamples = (callback) =>
  results = templateResults()
  [count, noOfFailed] = [0,0]
  # Hooks for the different tests
  callback ?= printResults
  testFiles 'valid', validSyntax, results.syntax.valid, ->
    testFiles 'invalid/syntaxErr', invalidSyntax, results.syntax.invalid, callback


# For watching and rerunning test suite
makeAndRun = ->
  exec "make all", (err, stdout, stderr) ->
    time = (new Date()).toTimeString().split(' ')[0]
    if stderr.split('\n').length > 3
      console.error "#{time} - Compilation failed! Not running tests."
      notify.send 'Make Failed!', false, true   # make sticky
    else
      testExamples ->
        if noOfFailed != 0
          console.error "#{time} - Tests produced #{noOfFailed} errors."
          notify.send "Failed #{noOfFailed} test cases!"
        else
          console.log "#{time} - Tests all passed."
          notify.send 'Tests passed!', true


# Extract watch argument
[watch, addr...] = process.argv[2..]
# If not being run to watch, then execute tests
if not watch then testExamples()
else
  makeScheduled = false
  fs.watch 'src', {persistent: true}, (event, filename) =>
    makeScheduled = true
    setTimeout (-> if makeScheduled
      makeScheduled = false
      makeAndRun()), 3000
    
