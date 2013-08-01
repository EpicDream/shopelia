class Shopelia.Controllers.ModalController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this


  open: (params) ->
    console.log('opening the modal')
    @view = new Shopelia.Views.Modal()
    Shopelia.Application.container.show(@view)
    @showSignUp()


  toto: (settings) ->
    @productView = new Shopelia.Views.ProductsIndex(model:@getProduct(),parent:this)
    view = new Shopelia.Views.UsersIndex(parent:this)
    @$('#modal-left').append(@productView.render().el)
    @setContentView(view)

  showSignUp : ->
    if @view is undefined
      @open
    Shopelia.vent.trigger("sign_up#show",@view.right)
