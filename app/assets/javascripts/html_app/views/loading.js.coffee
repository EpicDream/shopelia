class Shopelia.Views.Loading extends Backbone.View
  template: JST['loading']
  className: "loader"

  initialize:  ->
    _.bindAll this
    @parent = @options.parent


  render: ->
    $(@el).html(@template())
    $(@el).fadeIn('slow')
    @centerLoader()
    this


  centerLoader: ->
    console.log("center Loader")
    #$(@el).css
    #  "margin-top": ($(@el).outerHeight(true) - $(@parent.el).outerHeight(true))/2,
    #  "margin-left": ($(@parent.el).outerWidth(true) - $(@el).outerWidth(true))/2