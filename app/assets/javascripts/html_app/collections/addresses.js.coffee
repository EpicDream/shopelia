class Shopelia.Collections.Addresses extends Backbone.Collection
  model: "Shopelia.Models.Address"

  getDefaultAddress: ->
    r = @at(0)
    _.each(@models, (address) ->
      if address.get('is_default') == 1
        r = address
    )
    r