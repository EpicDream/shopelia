class Shopelia.Views.Description extends Shopelia.Views.ShopeliaView

  template: 'products/description'
  templateHelpers: {
    model: (attr) ->
      console.log(this)
      @product[attr]
  }

  ui: {
    description: ".full-description"
  }

  initialize: ->
    _.bindAll(this)

  onRender: ->
    Tracker.onDisplay('Product Description');

  onShow: ->
    $(@el).hide()
    @ui.description.children("table").addClass("table table-striped table-bordered")
    @ui.description.children("ul").addClass("unstyled")
    @ui.description.children("ul").each((i) ->
      $(this).children("li").each((i) ->
        text = $(this).text()
        result = text.split(":")
        if result.length > 1
          $(this).html("<span class=''>"+result[0]+"</span> : <strong>"+result[1]+"</strong>" )
      )
    )
    $(@el).slideDown('slow',() ->
      Shopelia.vent.trigger("modal#center")
    )



  close: ->
    that = this
    $(@el).slideUp('slow',() ->
      Shopelia.vent.trigger("modal#center")
      that.superClose()
    )

