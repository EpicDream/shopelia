class Shopelia.Controllers.ModalController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this


  open: (params) ->
    console.log('opening the modal')
    @view = new Shopelia.Views.Modal()
    Shopelia.Application.container.show(@view)
    @showHeader()
    @showSignUp()
    @showProduct(@getProduct())
    @view.center()

  showProduct: (product) ->
    Shopelia.vent.trigger("products#show",@view.left,product)

  showSignIn: ->
    Shopelia.vent.trigger("sign_in#show",@view.right)

  showSignUp: ->
    if @view is undefined
      @open
    Shopelia.vent.trigger("sign_up#show",@view.right)

  showHeader: ->
    Shopelia.vent.trigger("header#show",@view.header)

  showProductDescription:(product) ->
    Shopelia.vent.trigger("description#show",@view.top,product)

  showNotFound:(product) ->
    view = new Shopelia.Views.NotFound(model: product)
    @view.content.once("show", (view) ->
      Shopelia.vent.trigger("sign_up#close")
    )
    @view.content.show(view)


  order: ->
    order = new Shopelia.Models.Order({
                                      session: @getSession()
                                      product: @getProduct()
                                      })
    console.log(order)
    Shopelia.vent.trigger("sign_up#close")
    Shopelia.vent.trigger("sign_in#close")
    Shopelia.vent.trigger("order#show",@view.right,order)

  showThankYou: ->
    Shopelia.vent.trigger("thank_you#show",@view.right)

