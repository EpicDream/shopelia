class Shopelia.Views.ShopeliaView extends Backbone.View

  initialize:  ->
    _.bindAll this
    @parent = @options.parent


  getSession: ->
    if @options.session isnt undefined
      @options.session
    else if @parent isnt undefined
      @parent.getSession()
    else
      #console.log("getSession is undefined kill pierre")
      undefined

  getProduct:  ->
    console.log(Shopelia.Application.request("product"))
    Shopelia.Application.request("product")


  setSession: (session) ->
    @getRootView().options.session = session

  getRootView: ->
    if @parent is undefined
      return this
    else
      @parent.getRootView()
