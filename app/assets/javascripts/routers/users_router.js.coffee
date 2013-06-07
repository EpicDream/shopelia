class Shopelia.Routers.Users extends Backbone.Router

  initialize: ->
    @collection = new Shopelia.Collections.Users()
    view = new Shopelia.Views.UsersIndex(collection: @collection)
    $('#container').html(view.render().el)


