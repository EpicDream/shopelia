# NodeLogger
# Author : Vincent RENAUDINEAU
# Created : 2013-11-06

define 'node_logger', ['logger'], (logger) ->  
  logger.oldWrite = logger.write
  logger.write = (level, args) ->
    switch level
      when 'DEBUG'
        if logger.level >= logger.DEBUG
          console.log.apply(console, args)
      else
        logger.oldWrite(level, args)

  return logger