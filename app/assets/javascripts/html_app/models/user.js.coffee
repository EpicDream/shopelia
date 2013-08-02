class Shopelia.Models.User extends Backbone.RelationalModel
  urlRoot: "/api/users"
  relations: [{
              type: Backbone.HasMany,
              key: 'addresses',
              relatedModel: 'Shopelia.Models.Address'
              collectionType: 'Shopelia.Collections.Addresses'
              keySource: "addresses"
              keyDestination: "addresses_attributes"
              reverseRelation: {
                }
              },
              {
              type: Backbone.HasMany,
              key: 'payment_cards',
              relatedModel: 'Shopelia.Models.PaymentCard'
              collectionType: 'Shopelia.Collections.PaymentCards'
              keySource: "payment_cards"
              keyDestination: "payment_cards_attributes"
              reverseRelation: {
                }
              }]


  update: (attrs,callbacks) ->
    #console.log("In update login method")
    #console.log(@id)
    $.ajax({
           type: "PUT",
           url: 'api/users/' + @get('id'),
           data: {user: attrs},
           dataType: 'json',
           beforeSend: (xhr) ->
             xhr.setRequestHeader("Accept","application/json")
             xhr.setRequestHeader("Accept","application/vnd.shopelia.v1")
             xhr.setRequestHeader("X-Shopelia-ApiKey",Shopelia.developerKey)
             callbacks.beforeSend(xhr)
           success: callbacks.success
           error: callbacks.error
           })



