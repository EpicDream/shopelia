class Shopelia.Routers.Products extends Backbone.Router
  routes: {
  'checkout': 'showProduct'
  }

  showProduct: (params)  ->
    @product = new Shopelia.Models.Product(params)
    view = new Shopelia.Views.UsersIndex(product: @product)
    $('#container').html(view.render().el)

