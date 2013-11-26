###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: syntax.coffee
# Desc: Defines behaviour for parsing source code to generate an abstract
#       syntax tree. Exports the function `parse` which takes a string
#       representing wacc code and uses the generated pegjs parser to
#       attempt a parse. Any syntax errors are printed to stderr.
###############################################################################

path = require 'path'
parser = require path.join(__dirname, 'parser')

# Function to generate syntax error string
syntaxError = (e, src, filename) ->
  mssg = new Array
  mssg.push ">> #{e.message.replace(/"(.*?)"/ig, "\x1b[31m\"$1\"\x1b[0m")}"
  mssg.push "#{e.line}:#{e.column} - #{l = src.split('\n')[e.line - 1]}"
  mssg.push "#{(new Array(e.column + (mssg[1].length - l.length))).join(' ')}^"
  mssg = [">> Error in file '#{filename}'"].concat mssg if filename?
  return mssg.join('\n')

# Attempts to parse the source code in src
parse = (src, opt = {}) ->
  try
    parser.parse(src)
  catch err
    if err?.name == 'SyntaxError'
      mssg = syntaxError(err, src, opt['filename'])
      console.log mssg if opt['verbose']
      err.mssg = mssg
    throw err

# Export the parse function
module.exports = [ parse, syntaxError, parser.SyntaxError]
