###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112 amv12 skd212 ot612
# File: registers.coffee
# Desc: Register management class
###############################################################################

class Registers

  constructor: (@available = ("R#{r}" for r in [0..12])) ->
  update: (@available = rs) ->

module.exports = new Registers
