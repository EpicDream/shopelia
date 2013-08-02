class Shopelia.Controllers.ProductController extends Shopelia.Controllers.Controller

  show: (region,product) ->
    @view = new Shopelia.Views.ProductsIndex(model: product)
    region.show(@view)
    #if @model.isValid()
    #  expected_price_product = customParseFloat(@model.get('expected_price_product'))
    #  @model.set('expected_price_product',expected_price_product)
    #  expected_price_shipping  = customParseFloat(@model.get('expected_price_shipping'))
    #  @model.set('expected_price_shipping',expected_price_shipping)
    #  $(@el).html(@template(model: @model, merchant: @merchant))
    #  $('.description-content').append(@model.get('description'))
    #  descriptionView = new Shopelia.Views.Description(model: @model,parent: this)
    #  @description = $(descriptionView.render().el)
    #  this





  showDescription: ->
    #console.log("Show Product Infos")
    Tracker.onClick('Product Description')
    $("#modal-header").after(@description)
    that = this
    @description.animate({height:'100%'}, "slow")
    $("#modal-content").animate({height:'65px',opacity:0},"slow", () ->
      $(this).hide()
      $("#btn-hide-product-infos").click ->
        that.close(that.description)
    )
