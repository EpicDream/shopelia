class Shopelia.Views.Modal extends Shopelia.Views.ShopeliaView

  template: JST['modal']
  id: 'modal'
  className: 'span8'

  events:
    'click #close': 'close'

  initialize: ->
    #console.log(Shopelia.Views.ShopeliaView)
    Shopelia.Views.ShopeliaView.prototype.initialize.call(this)
    messageListener = (e) ->
      #console.log("set shopelia parent host")
      window.shopeliaParentHost = e.origin
      window.removeEventListener("message",messageListener)
    DOMContentLoadedListener = () ->
      window.addEventListener("message",messageListener
      , false)
      window.parent.postMessage("loaded", "*")
      window.removeEventListener("DOMContentLoaded",DOMContentLoadedListener)
    window.addEventListener("DOMContentLoaded",DOMContentLoadedListener
    , false)

  render: ->
    $(@el).html(@template())
    @open()
    $(@el).fadeIn('slow')
    that = this
    $(@el).click (e) ->
      e.stopPropagation()

    $(document).click ->
      if $("#productInfosIframe").length > 0
        that.productView.closeProducIframe()
      else
        that.close()
    this

  open: (settings) ->
    @productView = new Shopelia.Views.ProductsIndex(model:@getProduct(),parent:this)
    view = new Shopelia.Views.UsersIndex(parent:this)
    @$('#modal-left').append(@productView.render().el)
    @setContentView(view)


  close: ->
    #console.log("close please")
    $(@el).fadeOut({
                   duration: "fast",
                   complete: () ->
                    top.postMessage("deleteIframe",window.shopeliaParentHost)
                   })

  setContentView: (backboneView) ->
    @contentView = backboneView
    @contentView.parent = this
    el = @contentView.render().el
    $(el).fadeIn(500)
    @$('#modal-right-top').html(el)
    center($(window),$("#modal"))

  setHeaderLink: (text,target) ->
    $("#link-header").text(text)
    $("#link-header").unbind("click")
    $("#link-header").click ->
      target()

  #ToREFACTO
  addPasswordView : ->
    passwordView = new Shopelia.Views.NewPassword(parent:this)
    @$('#modal-right').append(passwordView.render().el)
    $(passwordView.render().el).hide()
