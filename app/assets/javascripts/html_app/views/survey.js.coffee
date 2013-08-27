class Shopelia.Views.Survey extends Shopelia.Views.Layout

  template: 'survey'

  initialize: ->
    _.bindAll(this)

  onRender: ->
    Tracker.onDisplay('Survey');

  onShow: ->
    console.log('allo')
    $(@el).fadeIn('slow',() ->
      Shopelia.vent.trigger("modal#center")
    )






