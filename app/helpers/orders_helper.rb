# -*- encoding : utf-8 -*-
module OrdersHelper
  def state
    case @order.state
      when "aborted"
        {state:"error",name:"Annulée"}
      when "completed"
        {state:"success",name:"Validée"}
      else
        {state:"warning",name:"En attente"}
    end
  end

  def order_completed?
    @order.state == :completed
  end

end
