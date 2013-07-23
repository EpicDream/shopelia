class Shopelia.Views.ProductsIndex extends Backbone.View

  template: JST['products/index']
  className: 'product'

  events:
    "click #btn-product-infos": "showProductInfos"

  initialize: ->
    _.bindAll this
    @iframe = @createIframe()
    @model.on('change', @render, @)
    $(@el).on('resize.product',() ->
      child_el.centerLoader()
    )
    view = new Shopelia.Views.Loading(parent: this)
    child_el = view.render().el
    $(@el).append(child_el)



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

  createIframe: ->
    console.log("Create Iframe")
    $iframe = $('<iframe></iframe>')
    $iframe.attr('id','productInfosIframe')
    console.log(@model.get('url'))
    $iframe.attr('src',@model.get('url'))
    $iframe.attr('scrolling','yes')
    $iframe.attr('frameborder','0')
    $iframe.css({
                border:"0px #FFFFFF none",
                opacity: "1"
                height: "0"
                })
    $iframe.attr('name',"shopeliaIframe")
    $iframe.attr('marginHeight',"0")
    $iframe.attr('marginWidth',"0")
    $iframe.attr('height',"100%")
    $iframe.attr('width',"100%")
    console.log($iframe)
    $iframe


  showProductInfos: ->
    console.log("Show Product Infos")
    if @model.get('merchant_name') is "Amazon France"
      window.open(@model.get('url'))
    else
      $iframe = @iframe
      $("#modal-header").after($iframe)
      that = this
      $iframe.animate({height:'550px'}, "slow")
      $("#modal-content").animate({height:'65px',opacity:0},"slow", () ->
        $(this).hide()
        $("#modal-footer").show()
        $("#btn-hide-product-infos").click ->
          that.closeProducIframe()
      )



  closeProducIframe: ->
    @iframe.animate({height:'0'}, "slow", () ->
      $(this).remove()
      $("#modal-footer").fadeOut("slow", () ->
        $("#modal-content").fadeIn("fast").animate({height:'100%',opacity:1},"slow")
      )

    )




