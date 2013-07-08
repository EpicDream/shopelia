class Shopelia.Views.Modal extends Backbone.View

  template: JST['modal']
  id: 'modal'
  className: 'span8'

  events:
    'click #close': 'close'

  initialize: ->
    _.bindAll this
    window.addEventListener("DOMContentLoaded", () ->
      window.parent.postMessage("loaded", "*")
      window.addEventListener("message", (e) ->
        console.log(e.origin)
        window.shopeliaParentHost = e.origin
      , false)
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
    console.log(shopeliaParentHost)
    top.postMessage("deleteIframe",window.shopeliaParentHost)







