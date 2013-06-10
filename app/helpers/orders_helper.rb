# -*- encoding : utf-8 -*-
module OrdersHelper
  def state
    case @order.state
      when :initialized
        {state: "initialization",name:"Initialisation"}
      when :processing
        {state: "processing",name:"Commande en cours"}
      when :pending
        {state:"warning",name:"En attente de traitement"}
      when :querying
        {state:"processing",name:"En attente de votre réponse"}
      when :completed
        {state:"success",name:"Validée"}
      else
        {state:"error",name:"Annulée"}
    end
  end

  def order_completed?
    @order.state == :completed
  end
  
  def order_querying?
    @order.state == :querying
  end

  def failure_reason
    case @order.error_code
    when "payment"
      "Le paiement de la commande a été refusé par votre banque"
    when "user"
      "Vous avez annulé la commande"
    when "account"
      "Impossible de créer un compte à votre nom chez le marchand"
    else
      "Le back office Shopelia n'a pas réussi à passer la commande suite à des erreurs techniques de notre part"
    end
  end

end

