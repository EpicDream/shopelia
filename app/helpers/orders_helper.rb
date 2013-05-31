module OrdersHelper
  def state
    case @order.state
      when "aborted"
        {state:"error",name:"Annul?"}
      when "completed"
        {state:"success",name:"Compl?te"}
      else
        {state:"warning",name:"En attente"}
    end
  end
end
