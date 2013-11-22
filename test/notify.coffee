###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112
# File: notify.coffee
# Desc: Returns OS dependent notification function
###############################################################################

exec = (require 'child_process').exec

mod = module?.exports = {}

# Configure for the os and supported notifications
mod.send = ->
exec 'type growlnotify', (err) ->
  if not err?
    mod.send = growl
  else
    exec 'type notify-send', (err) ->
      if not err?
        mod.send = notifySend
  
# Hook for the growl communication
# Mac OS X supported via growlnotify
growl = (mssg, positive, sticky) ->
  cmd = "growlnotify --image ./images"
  if not positive
    cmd = "#{cmd}/failed.png"
  else cmd = "#{cmd}/success.png"
  cmd = "#{cmd} -s" if sticky?
  exec "#{cmd} -m \"#{mssg}\""

# Hook for ubuntu
# Supported via the notify-send
notifySend = (mssg, positive) ->
  cmd = "notify-send -i "
  if not positive
    cmd = "#{cmd}/failed.png"
  else cmd = "#{cmd}/success.png"
  exec "#{cmd} \"#{mssg}\""



