# NodeLogger
# Author : Vincent RENAUDINEAU
# Created : 2013-11-06

define 'node_logger', ['log4js', 'logger'], (Log4js, logger) ->  

  Log4js.levels["VERB"] = new Log4js.levels.DEBUG.constructor(15000, "VERB")
  Log4js.levels["PRINT"] = new Log4js.levels.DEBUG.constructor(55000, "PRINT")
  Log4js.configure({"appenders": [{type: "logLevelFilter", level: "INFO", appender: {type:"console", layout: {type: 'messagePassThrough'}}}, {type: "file", absolute: true, filename: "/var/log/saturn/saturn.log", maxLogSize: 10485760, backups: 100, layout: {type: 'messagePassThrough'}}], replaceConsole: true})
  log4js = Log4js.getLogger()

  logger.oldWrite = logger.write
  logger.write = (level, args) ->
    str = if typeof args isnt "string" then logger.stringify(args) else args
    log4js.log(Log4js.levels[level], str.trim())

  return logger
