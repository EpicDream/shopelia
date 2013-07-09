class Shopelia.Views.Modal extends Backbone.View

  template: JST['modal']
  id: 'modal'
  className: 'span8'

  events:
    'click #close': 'close'

  initialize: ->
    _.bindAll this
    window.addEventListener("DOMContentLoaded", () ->
      window.addEventListener("message", (e) ->
        console.log("set shopelia parent host")
        window.shopeliaParentHost = e.origin
      , false)
      window.parent.postMessage("loaded", "*")
    , false)

  render: ->
    $(@el).html(@template())
    @open()
    #@$('input').bind("keydown",eraseError)
    this

  open: (settings) ->
    $('#modal').show()
    $('#container').show()
    productView = new Shopelia.Views.ProductsIndex(model:@options.product)
    view = new Shopelia.Views.UsersIndex(product: @options.product)
    #view = new Shopelia.Views.OrdersIndex(product: @options.product)
    #view = new Shopelia.Views.Greetings()
    @$('#modal-left').append(productView.render().el)
    @$('#modal-right').append(view.render().el)



  close: ->
    console.log("close please")
    top.postMessage("deleteIframe",window.shopeliaParentHost)








