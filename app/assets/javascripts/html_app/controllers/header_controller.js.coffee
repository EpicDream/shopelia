class Shopelia.Controllers.HeaderController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this
    @linkStack = []

  show: (region) ->
    @view = new Shopelia.Views.Header()
    region.show(@view)

  pushHeaderLink: (event,text,params) ->
    headerLink = {text: text,event:event,params:params}
    @linkStack.push(headerLink)
    @view.setHeaderLink(headerLink)

  popHeaderLink: (event,text,params)  ->
    headerLink = {text: text,event:event,params:params}
    @linkStack.pop(headerLink)
    length = @linkStack.length
    if length == 0
      @view.hideHeaderLink()
    else
      @view.setHeaderLink(_.last(@linkStack))

  popAll:(event) ->
    @linkStack = _.filter(@linkStack,(object) ->
      object.event isnt event
    )
    length = @linkStack.length
    if length == 0
      @view.hideHeaderLink()
    else
      @view.setHeaderLink(_.last(@linkStack))