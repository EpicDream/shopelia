class Shopelia.Views.Loading extends Shopelia.Views.ShopeliaView
  template: 'loading'
  className: "loader"

  onRender: ->
    $(@el).fadeIn('slow')

  onClose: ->
    $(@el).fadeOut('slow')
