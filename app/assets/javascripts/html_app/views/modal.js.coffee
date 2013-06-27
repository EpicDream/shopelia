class Shopelia.Views.Modal extends Backbone.View

  template: JST['modal']
  id: 'modal'
  className: 'span8'

  events:
    'click #close': 'close'

  initialize: ->
    _.bindAll this

  render: ->
    $(@el).html(@template())
    @open()
    this

  open: (settings) ->
    $('#modal').show()
    $('#container').show()
    productView = new Shopelia.Views.ProductsIndex(model:@options.product)
    view = new Shopelia.Views.UsersIndex(product: @options.product)
    @$('#modal-left').append(productView.render().el)
    @$('#modal-right').append(view.render().el)



  close: ->
    $('#container').remove()
    @remove()




