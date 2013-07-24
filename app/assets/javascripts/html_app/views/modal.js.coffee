class Shopelia.Views.Modal extends Backbone.View

  template: JST['modal']
  id: 'modal'
  className: 'span8'

  events:
    'click #close': 'close'
    'click #link-header': 'onActionClick'

  initialize: ->
    _.bindAll this
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
    @productView = new Shopelia.Views.ProductsIndex(model:@options.product)
    view = new Shopelia.Views.UsersIndex(product: @options.product)
    @$('#modal-left').append(@productView.render().el)
    @setContentView(view)


  close: ->
    #console.log("close please")
    $(@el).fadeOut({
                   duration: "fast",
                   complete: () ->
                    top.postMessage("deleteIframe",window.shopeliaParentHost)
                   })




  onActionClick: (e)->
    @contentView.onActionClick(e)


  setContentView: (backboneView) ->
    if @contentView isnt undefined
      @contentView.parent = undefined
    @contentView = backboneView
    @contentView.parent = this
    el = @contentView.render().el
    $(el).fadeIn(500)
    @$('#modal-right-top').html(el)
    if @contentView.InitializeActionButton != undefined
      @$("#link-header").show()
      @contentView.InitializeActionButton(@$("#link-header"))
    else
      @$("#link-header").hide()
    center($(window),$("#modal"))


  addPasswordView : ->
    passwordView = new Shopelia.Views.NewPassword()
    @$('#modal-right').append(passwordView.render().el)
    $(passwordView.render().el).hide()
