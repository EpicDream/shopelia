class Shopelia.Views.Description extends Shopelia.Views.ShopeliaView

  template: 'products/description'
  className: 'full-description'
  templateHelpers: {
    model: (attr) ->
      console.log(this)
      @product[attr]
  }


