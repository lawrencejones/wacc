#!/usr/bin/env coffee

fs = require 'fs'
parser = require '../src/grammar'

# Function to generate syntax error string
syntaxError = (e, src) ->
  mssg = new Array
  mssg.push ">> #{e.message.replace(/"(.*?)"/ig, "\x1b[31m\"$1\"\x1b[0m")}"
  mssg.push "#{e.line}:#{e.column} - #{l = src.split('\n')[e.line - 1]}"
  mssg.push "#{(new Array(e.column + (mssg[1].length - l.length))).join(' ')}^"
  return mssg.join('\n')

# Attempts to parse the source code in src
parseFile = (_, src) ->
  try
    parser.parse(src)
  catch err
    console.log syntaxError(err, src)
    process.exit 1

# Checks number of args
if process.argv.length < 3
  console.log "Source file required"
else fs.readFile(process.argv[2], 'utf8', parseFile)
