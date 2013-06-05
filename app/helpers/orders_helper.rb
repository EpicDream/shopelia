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

end
