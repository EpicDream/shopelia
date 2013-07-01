# -*- encoding : utf-8 -*-
module OrdersHelper
  def state
    case @order.state
      when :initialized
        {state: "initialization",name:"Initialisation"}
      when :preparing
        {state: "processing",name:"Commande en cours"}
      when :pending_agent
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
    when "billing"
      "Le paiement de la commande a été refusé par votre banque"
    when "user"
      "La commande a été annulée"
    when "merchant"
      case @order.message
      when "account"
        "Impossible de créer un compte à votre nom chez le marchand"
      when "stock"
        "Le produit demandé n'est plus en stock"
      end
    else
      "Le back office Shopelia n'a pas réussi à passer la commande suite à des erreurs techniques de notre part"
    end
  end

end

