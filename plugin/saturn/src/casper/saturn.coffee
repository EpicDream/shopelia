
casper = require('casper').create(
  verbose: true,
  logLevel: "warning",
  clientScripts: ["build/casper_injected.js"],
  waitTimeout: 30000,
)
utils = require('utils')
server = require('webserver').create()

HOST = "127.0.0.1"
PORT = casper.cli.get("port")
NODE_PORT = casper.cli.get("node_port")
initRequest = false


casper.on 'console', (line) ->
  logger.info('Fom console : ' + line)

casper.on "page.error", (msg, trace) ->
  logger.error(msg)
  # this.echo("Error:    " + msg, "ERROR");
  # this.echo("file:     " + trace[0].file, "WARNING");
  # this.echo("line:     " + trace[0].line, "WARNING");
  # this.echo("function: " + trace[0]["function"], "WARNING");

casper.on "error", (msg, trace) ->
  logger.error(msg)

casper.on "step.error", (msg) ->
  logger.error(msg)


casper.start()
casper.userAgent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/28.0.1500.71 Chrome/28.0.1500.71 Safari/537.36")
casper.page.viewportSize = { width: 1920, height: 1200 }

service = server.listen "#{HOST}:#{PORT}", (request, response) ->
  # Casper stop to wait.
  initRequest = true

  casper.echo "Incoming request."
  url = ""
  try
    prod = JSON.parse(request.post)
  catch err
    casper.echo "Fail to parse '#{request.post}'"
    return casper.exit()

  title = ""
  casper.echo "Product received : going to open '#{prod.url}'"
  casper.thenOpen(prod.url).then(->
    title = this.getTitle()
    this.echo "Title is #{title}"
    response.statusCode = 200
    response.write(title)
    response.close()
  )
  casper.run(->
    this.echo "Going to quit casper."
    return casper.exit()
  )

casper.echo "Server launch. Listen on #{HOST}:#{PORT}"
casper.echo "Send ready signal to NodeJS server on port #{NODE_PORT}"

casper.evaluate( (host, node_port, port) ->
  __utils__.sendAJAX("http://#{host}:#{node_port}/casper-ready?session=#{port}  ", 'POST')
, HOST, NODE_PORT, PORT)
casper.then ->
  casper.echo("Ajax request sent.")
casper.waitFor ->
  initRequest
casper.run()