class Shopelia.Views.ProductsIndex extends Shopelia.Views.ShopeliaView

  template: JST['products/index']
  className: 'product box'

  events:
    "click #product-infos": "showProductInfos"
    "click #full-description": "showDescription"

  initialize: ->
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)
    @iframe = @createIframe()
    @model.on('change', @render, @)
    view = new Shopelia.Views.Loading(parent: this)
    child_el = view.render().el
    $(@el).append(child_el)



  render: ->
    if @model.isValid()
      expected_price_product = customParseFloat(@model.get('expected_price_product'))
      @model.set('expected_price_product',expected_price_product)
      expected_price_shipping  = customParseFloat(@model.get('expected_price_shipping'))
      @model.set('expected_price_shipping',expected_price_shipping)
      $(@el).html(@template(model: @model, merchant: @merchant))
      $('.description-content').append(@model.get('description'))
      descriptionView = new Shopelia.Views.Description(model: @model,parent: this)
      @description = $(descriptionView.render().el)
      this
    else if @model.get('found') isnt undefined and @model.get('found') is false
      view = new Shopelia.Views.NotFound(model:@model,parent: this)
      $(@el).html(view.render().el)
    else
      $(@el).html()
      this

  createIframe: ->
    #console.log("Create Iframe")
    $iframe = $('<iframe></iframe>')
    $iframe.attr('id','productInfosIframe')
    #console.log(@model.get('url'))
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
    $iframe


  showProductInfos: ->
    #console.log("Show Product Infos")
    Tracker.onClick('Product Informations')
    #console.log(@model.get('allow_iframe'))
    if @model.get('allow_iframe') == 0 or Shopelia.Adblock
      window.open(@model.get('url'))
    else
      $iframe = @iframe
      $("#modal-header").after($iframe)
      that = this
      $iframe.animate({height:'550px'}, "slow")
      $("#modal-content").animate({height:'65px',opacity:0},"slow", () ->
        $(this).hide()
        $("#btn-hide-product-infos").click ->
          that.close(that.iframe)
      )



  close: ($element) ->
    $element.animate({height:'0'}, "slow", () ->
      $(this).remove()
      $("#modal-content").fadeIn("fast").animate({height:'100%',opacity:1},"slow")
    )

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


