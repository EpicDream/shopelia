class Shopelia.Controllers.AppController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this
    @initializeReqRes()
    @session = new Shopelia.Models.Session()



  initializeReqRes: ->
    Shopelia.Application.reqres.setHandler("product", @getProduct)
    Shopelia.Application.reqres.setHandler("session", @getSession)

  getProduct : ->
    return @product

  getSession : ->
    return @session


  openModal: (params) ->
    if params.developer isnt undefined
      Shopelia.developerKey = params.developer
    @product = new Shopelia.Models.Product(params)
    Shopelia.vent.trigger("modal#open",params)



