# NodeLogger
# Author : Vincent RENAUDINEAU
# Created : 2013-11-06

define 'node_logger', ['log4js', 'logger'], (Log4js, logger) ->  
  Log4js.configure({"appenders": [{type:"console", level: "Info", layout: {type: 'messagePassThrough'}}, {type: "file", absolute: true, filename: "/var/log/saturn/saturn.log", maxLogSize: 1048576, backups: 10, layout: {type: 'messagePassThrough'}}]})
  log4js = Log4js.getLogger()

  logger.oldWrite = logger.write
  logger.write = (level, args) ->
    str = logger.stringify(args)
    log4js.log(level, str.trim())
    # switch level
    #   when 'DEBUG'
    #     if logger.level >= logger.DEBUG
    #       console.log(str)
    #   else
    #     logger.oldWrite(level, [str])

  return logger
