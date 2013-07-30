class Shopelia.Views.Loading extends Shopelia.Views.ShopeliaView
  template: JST['loading']
  className: "loader"

  initialize:  ->
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)


  render: ->
    $(@el).html(@template())
    $(@el).fadeIn('slow')
    @centerLoader()
    this


  centerLoader: ->
    #console.log("center Loader")
    #$(@el).css
    #  "margin-top": ($(@el).outerHeight(true) - $(@parent.el).outerHeight(true))/2,
    #  "margin-left": ($(@parent.el).outerWidth(true) - $(@el).outerWidth(true))/2