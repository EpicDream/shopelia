class Shopelia.Controllers.ModalController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this

  open: (params) ->
    console.log('opening the modal')
    @view = new Shopelia.Views.Modal()
    Shopelia.Application.container.show(@view)
    @showHeader()
    @showContent()
    @center()

  showContent: ->
    if @view is undefined
      @open
    Shopelia.vent.trigger("modal_content#show",@view.content)
    @view.showCloseButton()

  showHeader: ->
    Shopelia.vent.trigger("header#show",@view.header)

  showProductDescription:(product) ->
    @view.hideCloseButton()
    Shopelia.vent.trigger("modal_content#hide")
    Shopelia.vent.trigger("description#show",@view.top,product)

  showAddToCart: ->
    Shopelia.vent.trigger('add_to_cart#show',@view.content)

  showProductNotAvailable:(product) ->
    if product.get('ready') == 1
      view = new Shopelia.Views.NotAvailable(model: product)
    else
      view = new Shopelia.Views.NotFound(model: product)
    @view.content.once("show", (view) ->
      Shopelia.vent.trigger("sign_up#close")
      Shopelia.vent.trigger("header#hide_all")
    )
    @view.content.show(view)

  center: (animate) ->
    animate = (animate == undefined  or animate)
    @view.center(animate)


