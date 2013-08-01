class Shopelia.Controllers.ModalController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this


  open: (params) ->
    console.log('opening the modal in ' + JSON.stringify this )
    console.log(params)
    Shopelia.vent.trigger("modal#test")

  test: ->
    alert 'rjjtjtjtbnoergbekrmhfgeilz'
    @dispose()

