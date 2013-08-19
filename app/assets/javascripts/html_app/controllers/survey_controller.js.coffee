class Shopelia.Controllers.SurveyController extends Shopelia.Controllers.Controller

  initialize: ->
    _.bindAll this

  show:(region) ->
    @view = new Shopelia.Views.Survey()
    region.show(@view)


