class Shopelia.Views.ProductsIndex extends Shopelia.Views.ShopeliaView

  template: 'products/index'
  templateHelpers: {
    model: (attr) ->
      @product[attr]
    format: (v) ->
      window.formatCurrency(v)
    formatShipping: (v) ->
      window.formatShipping(v)
  }
  className: 'product box'

  ui: {
    shipping: ".shipping"
    shipping_info: "#shipping-info"
    description: ".product-description"
    description_link: "#full-description"
    cashfront: ".cashfront"
    strikeout: ".price-strikeout"
    option1: "#option1-box"
    option2: "#option2-box"
    option3: "#option3-box"
    option4: "#option4-box"
  }
  events:
    "click .option-img": "onSelectVersion"
    "change .option-select": "onSelectVersion"
    'click #full-description': 'onDescriptionClick'

  initialize: ->
    @model.on('change', @render, @)

  onRender: ->
    if @model.get('shipping_info')
      @ui.shipping_info.show()
    if @model.get('expected_price_strikeout') > 0
      @ui.strikeout.show()
    if @model.get('expected_cashfront_value') > 0
      @ui.cashfront.show()
    unless @model.get('description')
      @ui.description.remove()
      @ui.description_link.remove()
    @buildOption("option1", @ui.option1)
    @buildOption("option2", @ui.option2)
    @buildOption("option3", @ui.option3)
    @buildOption("option4", @ui.option4)

  buildOption: (key, ui) ->
    versions = @model.get('versions')
    if versions && versions.length > 0 && versions[0][key]
      added = []
      md5 = @model.get(key + '_md5')
      r = ""
      if versions[0][key]["text"]
        r += "<select class='option-select' id='" + key + "'>"
        for i in [0..versions.length - 1] by 1
          value = versions[i][key + "_md5"]
          text = $.trim(versions[i][key]["text"])
          if !_.contains(added, text)
            if value == md5
              selected = "selected"
            else
              selected = ""
            r += "<option " + selected + " value='" + value + "'>" + text + "</option>"
            added.push(text)
        r += "</select>"
      if versions[0][key]["src"]
        for i in [0..versions.length - 1] by 1
          value = versions[i][key + "_md5"]
          if !_.contains(added, value)
            if value == md5
              selected = "option-img-selected"
            else
              selected = ""
            r += "<img class='option-img " + selected + "' id='" + value + "' data-option='" + key + "' src='" + versions[i][key]["src"] + "'> "
            added.push(value)
      ui.html(r)

  onSelectVersion: (e) ->
    if e.type == "click"
      key = $(e.target).data("option")
      value = e.target.id
    else
      key = e.target.id
      value = $("#" + key).val()
    @model.setVersion(key, value)

  onDescriptionClick: ->
    Shopelia.vent.trigger("modal#show_product_description",@model)