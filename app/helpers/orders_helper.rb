# -*- encoding : utf-8 -*-
module OrdersHelper
  def state
    case @order.state
      when :initialized
        {state: "initialization",name:"Initialisation"}
      when :processing
        {state: "processing",name:"Commande en cours"}
      when :pending
        {state:"warning",name:"En attente"}
      when :completed
        {state:"success",name:"Validée"}
      else
        {state:"error",name:"Annulée"}
    end
  end

  def order_completed?
    @order.state == :completed
  end
  
  def failure_reason
    case @order.error_code
    when "vulcain"
    when "vulcain_api"
      "Le back office Shopelia est en maintenance"
    when "payment"
      "Le paiement de la commande a été refusé par votre banque"
    when "price"
      "Le prix total de votre commande a augmenté chez le marchand !"
    when "account"
      "Impossible de créer un compte à votre nom chez le marchand"
    end
  end

end

