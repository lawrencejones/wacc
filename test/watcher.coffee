###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: watcher.coffee
# Desc: Watches the source files for change and reruns the testsuite if it
#       detects any.
###############################################################################

fs = require 'fs'
test = require './_entry'

fs.watch 'src', {persistent: true}, (event, filename) ->
  console.log filename
