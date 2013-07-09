namespace :shopelia do
  namespace :orders do
    
    desc "Manage orders life cycle"
    task :monitor => :environment do
      Order.delayed.each { |order| order.notify_creation }
      Order.expired.each { |order| order.user_time_out }
      Order.canceled.each { |order| order.reject "price_rejected" }
      Order.preparing_stale.each { |order| order.vulcain_time_out }

      Leftronic.new.clear("shopelia_orders_pending_agent") if Order.where(state_name:"pending_agent").count == 0
      Leftronic.new.clear("shopelia_orders_preparing") if Order.where(state_name:"preparing").count == 0
      Leftronic.new.clear("shopelia_sound")
		
      status = Order.where(state_name:"pending_agent").count > 0 ? 100 : 0
      Leftronic.new.push_number("shopelia_status", status)			
    end

  end
end
