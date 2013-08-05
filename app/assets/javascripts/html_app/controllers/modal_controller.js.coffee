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

  showProduct: (product) ->
    Shopelia.vent.trigger("product#show",@view.left,product)

  showSignIn: ->
    Shopelia.vent.trigger("sign_in#show",@view.right)

  showSignUp: ->
    if @view is undefined
      @open
    Shopelia.vent.trigger("sign_up#show",@view.right)

  showHeader: ->
    Shopelia.vent.trigger("header#show",@view.header)

  order: ->
    order = new Shopelia.Models.Order({
                                      session: @getSession()
                                      product: @getProduct()
                                      })
    console.log(order)
    Shopelia.vent.trigger("order#show",@view.right,order)

  showThankYou: ->
    Shopelia.vent.trigger("thank_you#show",@view.right)

