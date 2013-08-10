class Shopelia.Routers.AppRouter extends Backbone.Marionette.AppRouter
  controller: new Shopelia.Controllers.AppController()
  appRoutes: {
    'checkout': 'openModal'
  }

