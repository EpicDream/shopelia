class Shopelia.Controllers.ModalController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this


  open: (params) ->
    console.log('opening the modal')
    @view = new Shopelia.Views.Modal()
    Shopelia.Application.container.show(@view)
    @showHeader()
    @showContent()
    @view.center()

  showContent: ->
    if @view is undefined
      @open
    Shopelia.vent.trigger("modal_content#show",@view.content)

  showHeader: ->
    Shopelia.vent.trigger("header#show",@view.header)

  showProductDescription:(product) ->
    Shopelia.vent.trigger("description#show",@view.top,product)
    Shopelia.vent.trigger("modal_content#hide")


  showNotFound:(product) ->
    view = new Shopelia.Views.NotFound(model: product)
    @view.content.once("show", (view) ->
      Shopelia.vent.trigger("sign_up#close")
    )
    @view.content.show(view)




