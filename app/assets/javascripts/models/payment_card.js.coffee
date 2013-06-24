class Shopelia.Models.PaymentCard extends Backbone.Model
  paramRoot: "payment_card",
  urlRoot: "/api/payment_cards",


  validate: (attrs) ->

    errors = {}

    if(attrs.number.length == 0)
      errors["number"] = "Card number required"

    if(attrs.exp_month.length == 0)
      errors["exp_month"] = "Expiration month required"

    if(attrs.exp_year.length == 0)
      errors["exp_year"] ="Expiration year required"

    if(attrs.cvv.length == 0)
      errors["cvv"] = "phone required"

    console.log(_.size(errors))
    if _.size(errors) > 0
      console.log(errors)
      errors
