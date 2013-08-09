class Shopelia.Collections.PaymentCards extends Backbone.Collection
  model: "Shopelia.Models.PaymentCard"

  getDefaultPaymentCard: ->
    @at(0)