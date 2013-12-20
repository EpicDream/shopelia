# CapserLogger
# Author : Vincent RENAUDINEAU
# Created : 2013-11-06

define 'casper_logger', ['logger'], (logger) ->
  casp = (casper? && casper) || window.__utils__
  return logger if ! casp?
  
  logger.oldWrite = logger.write
  logger.write = (level, args) ->
    caspLvl = switch level
      when 'FATAL', 'ERROR' then "error"
      when 'WARN', 'WARNING' then "warning"
      when 'DEBUG' then "debug"
      else "info"
    casp.echo(logger.stringify(args), caspLvl)

  return logger
