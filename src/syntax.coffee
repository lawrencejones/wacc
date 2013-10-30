###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: syntax.coffee
# Desc: Defines behaviour for parsing source code to generate an abstract
#       syntax tree. Exports the function `parseSrc` which takes a string
#       representing wacc code and uses the generated pegjs parser to
#       attempt a parse. Any syntax errors are printed to stderr.
###############################################################################

fs = require 'fs'
parser = require './parser'

# Function to generate syntax error string
syntaxError = (e, src) ->
  mssg = new Array
  mssg.push ">> #{e.message.replace(/"(.*?)"/ig, "\x1b[31m\"$1\"\x1b[0m")}"
  mssg.push "#{e.line}:#{e.column} - #{l = src.split('\n')[e.line - 1]}"
  mssg.push "#{(new Array(e.column + (mssg[1].length - l.length))).join(' ')}^"
  return mssg.join('\n')

# Attempts to parse the source code in src
parseSrc = (src) ->
  try
    parser.parse(src)
  catch err
    console.log syntaxError(err, src)
    throw err

# Export the parseSrc function
module.exports = parseSrc
