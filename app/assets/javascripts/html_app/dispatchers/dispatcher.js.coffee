class Shopelia.Dispatchers.Dispatcher
  controllers: {}

  constructor: (vent) ->
    console.log("initialize dispatcher")
    console.log(vent)
    _.bindAll(this)
    vent.on("all",@dispatch)


  dispatch: (eventName) ->
    console.log("begin dispatcher")
    if eventName.indexOf("#") != -1
      result = eventName.split("#")
      controllerName = result[0].normalizeName() + 'Controller'
      console.log(controllerName)
      args = Array.prototype.slice.call(arguments,1,arguments.length)
      action = result[1].normalizeName().uncapitalize()
      console.log(action)
      if @controllers[controllerName] is undefined
        controller = new Shopelia.Controllers[controllerName]()
        @controllers[controllerName] = controller
      else
        controller = @controllers[controllerName]
      unless  controller is undefined  || controller[action] is undefined
        controller[action].apply(controller,args)



  dispose: (controller) ->
    temp = {}
    @controllers = _.each(
        @controllers,(value,key) ->
          if controller != value
            temp[key] = value
    )
    @controllers = temp
    console.log(@controllers)

