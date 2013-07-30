class Shopelia.Views.Description extends Shopelia.Views.ShopeliaView

  template: JST['products/description']
  className: 'full-description'

  initialize: ->
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)


  render: ->
    $(@el).html(@template(model: @model))
    #console.log("description view")
    #console.log(@options)
    $(@el).append(@model.get("description"))
    this