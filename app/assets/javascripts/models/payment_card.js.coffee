class Shopelia.Models.PaymentCard extends Backbone.Model
  urlRoot: "/api/payment_cards",


  validate: (attrs) ->

    errors = {}
    console.log(attrs.payment_card)
    if(attrs.payment_card.number.length == 0)
      errors["number"] = "Card number required"

    if(attrs.payment_card.exp_month.length == 0)
      errors["exp_month"] = "Expiration month required"

    if(attrs.payment_card.exp_year.length == 0)
      errors["exp_year"] ="Expiration year required"

    if(attrs.payment_card.cvv != undefined && attrs.payment_card.cvv.length == 0)
      errors["cvv"] = "phone required"

    console.log(_.size(errors))
    if _.size(errors) > 0
      console.log(errors)
      errors
