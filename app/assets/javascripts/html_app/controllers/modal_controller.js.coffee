class Shopelia.Controllers.ModalController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this


  open: (params) ->
    console.log('opening the modal')
    @view = new Shopelia.Views.Modal()
    Shopelia.Application.container.show(@view)
    @showSignUp()
    @showProduct(@getProduct())

  showProduct: (product) ->
    Shopelia.vent.trigger("product#show",@view.left,product)

  showSignUp : ->
    if @view is undefined
      @open
    Shopelia.vent.trigger("sign_up#show",@view.right)
