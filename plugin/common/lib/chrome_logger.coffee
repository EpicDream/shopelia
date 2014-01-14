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

  logger.format = (level, args) ->
    format = logger._oldFormat(level, args)
    format[0] = format[0].replace(/^%c/, '')
    format

  logger.header = (level, date) ->
    header = logger._oldHeader(level, date)
    header[0] = "%c" + header[0]
    header

  logger._log2 = (level, args) ->
    levelBck = logger.level
    logger.level = logger.NONE
    argsArray = logger._oldLog2(level, args)
    logger.level = levelBck

    logger.write(level, logger.chromify(level, args)) if logger[level] <= logger.level
    logger.writeToFile(argsArray) if logger.file_level >= logger[level]
    logger.writeToBD(level, argsArray) if logger.db_level >= logger[level]
    argsArray

  logger.chromify = (level, _arguments) ->
    args = logger.header(level)
    args.splice 1, 0, switch level
      when 'FATAL', 'ERROR' then 'color: #f00'
      when 'WARN', 'WARNING' then 'color: #f60'
      when 'INFO' then 'color: #00f'
      when 'GOOD' then 'color: #090'
      when 'DEBUG', 'TRACE' then 'color: #000'
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
      yesteday = new Date(Date.now() - 1000*60*60*24) # Yesteday
      for i in [0...entries.length]
        entry = entries[i]
        m = entry.name.match(/log-\d+.txt/)
        if i < min || m && parseInt(m, 10) < yesteday
          entry.remove logger.onRemoveEntry(entry.name)

  logger.onRemoveEntry = (name) ->
    return ->
      console.log(name, "deleted.")

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
        logger.printEntry(entry)
    , errorHandler)

  logger.printEntry = (entry) ->
    entry.file( (file) ->
      reader = new FileReader()
      reader.onloadend = (e) ->
        console.log this.result
      reader.readAsText file
    , errorHandler)

  window.webkitRequestFileSystem(window.TEMPORARY, 1*1024*1024, (fs) ->
    logger.filesystem = fs
    logger.openNewFile()
  , errorHandler)

  #///////  END LOG TO FILE ///////

  #////////////////////////////////////////
  #//          LOG TO LOCAL DB
  #////////////////////////////////////////

  dbSize = 32*1024*1024
  while true
    try
      logger.db = openDatabase 'viking_logger', '1.0', 'Viking Logger',  dbSize
      logger.info "Database open with size = " + (dbSize / 1024) + " ko."
      break
    catch err
      if dbSize > 1024
        dbSize /= 2
      else
        logger.warn "Did not succeed to open database."
        break

  if logger.db?
    logger.db.transaction (tx) ->
      tx.executeSql "CREATE TABLE IF NOT EXISTS logs(time BIGINT, level INT, caller VARCHAR, content TEXT)"

  logger.writeToBD = (level, args) ->
    return if ! logger.db
    console.assert(typeof level is 'string', 'level must be a string');
    console.assert(typeof args is 'object' && args instanceof Array, 'args must be an Array');
    content = logger.stringify(args)
    logger.db.transaction (tx) ->
      tx.executeSql 'INSERT INTO logs (time, level, caller, content) VALUES (?, ?, ?, ?)', [Date.now(), logger[level] || level, '', content]

  logger.readFromDB = (level_min, nb) ->
    return if ! logger.db
    level_min ?= logger.ALL
    level_min = logger[level_min] unless typeof level_min is 'number'
    logger.db.transaction (tx) ->
      tx.executeSql 'SELECT * FROM logs WHERE level <= ? LIMIT ?;', [level_min, nb || 1000], (tx, results) ->
        for i in [0...results.rows.length]
          row = results.rows.item(i)
          color = logger.chromify(logger.code2str[row.level], [])[1]
          console.log("%c"+row.content, color)

  logger.cleanDB = (minutes) ->
    return if ! logger.db
    limit = Date.now() - 1000*60*(minutes || 60*2) # 2 heures
    logger.db.transaction (tx) ->
      tx.executeSql "DELETE FROM logs WHERE time <= ?;", [limit]

  # Clean DB every hour
  if logger.db
    setInterval(logger.cleanDB, 1000*60*30); # 30 minutes
    setTimeout(logger.cleanDB, 200);

  #///////  END LOG TO DB ///////

  return logger
