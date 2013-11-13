# ChromeLogger
# Author : Vincent RENAUDINEAU
# Created : 2013-11-06

define 'chrome_logger', ['logger'], (logger) ->
  return logger unless chrome?

  logger._oldLog2 = logger._log2
  logger._oldHeader = logger.header
  logger._oldFormat = logger.format

  logger.file_level = 0
  logger.db_level = 3

  logger.format = (level, caller, args) ->
    format = logger._oldFormat(level, caller, args)
    format[0] = format[0].replace(/^%c/, '')
    format

  logger.header = (level, caller, date) ->
    "%c" + logger._oldHeader(level, caller, date)

  logger._log2 = (level, caller, args) ->
    levelBck = logger.level
    logger.level = logger.NONE
    argsArray = logger._oldLog2(level, caller, args)
    logger.level = levelBck

    logger.write(level, logger.chromify(level, caller, args)) if logger[level] <= logger.level
    logger.writeToFile(argsArray) if logger.file_level >= logger[level]
    logger.writeToBD(level, caller, argsArray) if logger.db_level >= logger[level]
    argsArray

  logger.chromify = (level, caller, _arguments) ->
    args = [logger.header(level, caller)]
    args.push switch level
      when 'FATAL', 'ERROR' then 'color: #f00'
      when 'WARN', 'WARNING' then 'color: #f60'
      when 'INFO' then 'color: #00f'
      when 'GOOD'then 'color: #090'
      when 'DEBUG'then 'color: #000'
      else 'color: #000'
    for arg in _arguments
      args[0] += if typeof arg is 'string' || typeof arg is 'number' || typeof arg is 'boolean' then " %s"
      else if typeof arg is 'object' && arg instanceof RegExp then args[0] += " %s"
      else if typeof arg is 'object' && arg instanceof Date then args[0] += " %s"
      else if typeof arg is 'object' && arg instanceof window.HTMLElement then args[0] += " %o"
      else " %O"
      args.push(arg)
    return args

  #////////////////////////////////////////
  #//          LOG TO FILE
  #////////////////////////////////////////

  logger.nbLine = 0

  errorHandler = (e) ->
    msg =  switch e.code
      when FileError.QUOTA_EXCEEDED_ERR then 'QUOTA_EXCEEDED_ERR'
      when FileError.NOT_FOUND_ERR then 'NOT_FOUND_ERR'
      when FileError.SECURITY_ERR then 'SECURITY_ERR'
      when FileError.INVALID_MODIFICATION_ERR then 'INVALID_MODIFICATION_ERR'
      when FileError.INVALID_STATE_ERR then 'INVALID_STATE_ERR'
      else 'Unknown Error'
    console.error('Error: ' + msg)

  logger.openNewFile = (callback) ->
    callback ?= ->
    filename = "log-" + (new Date()).getTime() + ".txt"
    logger.nbLine = 0
    logger.filesystem.root.getFile( filename, {create: true}, (entry) ->
      logger.fileEntry = entry
    , errorHandler)
    logger.removeOldFiles()

  logger.removeOldFiles = ->
    logger.filesystem.root.createReader().readEntries (entries) ->
      # Sort entries by date
      entries_tab = []
      for entry in entries
        entries_tab.push(entry)
      entries = entries_tab.sort (e1, e2) ->
        if e1.name < e2.name then -1
        else if e1.name > e2.name then 1
        else 0
      min = entries.length - 10
      d = new Date(Date.now() - 1000*60*60*24) # Yesteday
      for i in [0...entries.length]
        entry = entries[i]
        m = entry.name.match(/log-\d+.txt/)
        if i < min || m && parseInt(m, 10) < d
          entry.remove () ->
            console.log(entry.name, "deleted.")

  logger.writeToFile = (args) ->
    return if ! logger.fileEntry
    line = logger.stringify(args) + '\n'
    logger.fileEntry.createWriter( (fileWriter) ->
      # Create a new Blob and write it to log.txt.
      blob = new Blob([line], {type: 'text/plain'})
      fileWriter.seek fileWriter.length
      fileWriter.write blob

      logger.nbLine += 1
      if logger.nbLine > 1000
        logger.openNewFile()
    , errorHandler)

  logger.printLastLogs = ->
    logger.filesystem.root.createReader().readEntries( (entries) ->
      # Sort entries by date
      entries_tab = []
      for entry in entries
        entries_tab.push(entry)
      entries = entries_tab.sort (e1, e2) ->
        if e1.name < e2.name then -1
        else if e1.name > e2.name then 1
        else 0
      # Print them all
      for entry in entries
        entry.file( (file) ->
          reader = new FileReader()
          reader.onloadend = (e) ->
            console.log this.result
          reader.readAsText file
        , errorHandler)
    , errorHandler)

  window.webkitRequestFileSystem(window.TEMPORARY, 1*1024*1024, (fs) ->
    logger.filesystem = fs
    logger.openNewFile()
  , errorHandler)

  #///////  END LOG TO FILE ///////

  #////////////////////////////////////////
  #//          LOG TO LOCAL DB
  #////////////////////////////////////////

  logger.db = openDatabase 'viking_logger', '1.0', 'Viking Logger',  30*1024*1024
  logger.db.transaction (tx) ->
    tx.executeSql "CREATE TABLE IF NOT EXISTS logs(time BIGINT, level INT, caller VARCHAR, content TEXT)"

  logger.writeToBD = (level, caller, args) ->
    console.assert(typeof level is 'string', 'level must be a string');
    console.assert(typeof caller is 'string', 'caller must be a string');
    console.assert(typeof args is 'object' && args instanceof Array, 'args must be an Array');
    content = logger.stringify(args)
    logger.db.transaction (tx) ->
      tx.executeSql 'INSERT INTO logs (time, level, caller, content) VALUES (?, ?, ?, ?)', [Date.now(), logger[level] || level, caller, content]

  logger.readFromDB = (level_min, nb) ->
    level_min ?= logger.ALL
    level_min = logger[level_min] unless typeof level_min is 'number'
    logger.db.transaction (tx) ->
      tx.executeSql 'SELECT * FROM logs WHERE level <= ? LIMIT ?;', [level_min, nb || 1000], (tx, results) ->
        for i in [0...results.rows.length]
          row = results.rows.item(i)
          header = logger.header(logger.code2str[row.level], row.caller, new Date(row.time))
          console.log("%c"+row.content, logger.chromify(logger.code2str[row.level], '', [])[1])

  logger.cleanDB = (minutes) ->
    limit = Date.now() - 1000*60*(minutes || 60*2) # 2 heures
    logger.db.transaction (tx) ->
      tx.executeSql "DELETE FROM logs WHERE time <= ?;", [limit]

  # Clean DB every hour
  setInterval(logger.cleanDB, 1000*60*30); # 30 minutes
  setTimeout(logger.cleanDB, 200);

  #///////  END LOG TO DB ///////

  return logger
