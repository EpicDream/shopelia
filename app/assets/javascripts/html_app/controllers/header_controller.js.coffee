class Shopelia.Controllers.HeaderController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this

  show: (region) ->
    @view = new Shopelia.Views.Header()
    region.show(@view)

  setHeaderLink: (text,event,params) ->
    @view.setHeaderLink(text,event,params)