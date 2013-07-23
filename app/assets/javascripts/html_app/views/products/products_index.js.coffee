class Shopelia.Views.ProductsIndex extends Backbone.View

  template: JST['products/index']
  className: 'product'

  initialize: ->
    _.bindAll this
    @model.on('change', @render, @)
    $(@el).on('resize.product',() ->
      child_el.centerLoader()
    )
    view = new Shopelia.Views.Loading(parent: this)
    child_el = view.render().el
    $(@el).append(child_el)
    view.centerLoader()



  render: ->
    console.log(@model)
    if @model.isValid()
      expected_price_product = customParseFloat(@model.get('expected_price_product'))
      @model.set('expected_price_product',expected_price_product)
      expected_price_shipping  = customParseFloat(@model.get('expected_price_shipping'))
      @model.set('expected_price_shipping',expected_price_shipping)
      $(@el).html(@template(model: @model, merchant: @merchant))
      this
    else
      $(@el).html()
      this

