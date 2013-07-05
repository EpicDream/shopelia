class Shopelia.Routers.Products extends Backbone.Router
  routes: {
  'checkout': 'showModal'
  }

  initialize: ->
    _.bindAll this
    $(window).on('resize.modal',@center)
    $(window).on('load',@center)

  showModal: (params)  ->
    @product = new Shopelia.Models.Product(params)
    view = new Shopelia.Views.Modal(product: @product)
    $('body').append(view.render().el)
    @center()

  center: ->
    top =undefined
    left = undefined
    top = Math.max($(window).height() - $('#modal').height(), 0) / 2
    left = Math.max($(window).width() - $('#modal').outerWidth(), 0) / 2

    $('#modal').css
      top: top
      left: left
