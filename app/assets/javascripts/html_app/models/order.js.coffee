class Shopelia.Models.Order extends Backbone.RelationalModel
  name: "order"
  urlRoot: "/api/orders"
  relations: [{
              type: Backbone.HasOne,
              key: 'product',
              relatedModel: 'Shopelia.Models.Product'
              includeInJSON: false
              },
              {
              type: Backbone.HasOne,
              key: 'session',
              relatedModel: 'Shopelia.Models.Session'
              includeInJSON: false
              }]