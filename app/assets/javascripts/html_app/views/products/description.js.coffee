class Shopelia.Views.Description extends Backbone.View

  template: JST['products/description']
  className: 'full-description'

  initialize: ->
    _.bindAll this

  render: ->
    $(@el).html(@template(model: @model))
    console.log("description view")
    console.log(@options)
    $(@el).append(@model.get("description"))
    this