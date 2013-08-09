class Shopelia.Collections.Addresses extends Backbone.Collection
  model: "Shopelia.Models.Address"

  getDefaultAddress: ->
    @at(0)