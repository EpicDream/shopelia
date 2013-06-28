namespace :shopelia do
  namespace :orders do
    
    desc "Manage orders life cycle"
    task :monitor => :environment do
      Order.delayed.each { |order| order.notify_creation }
      Order.expired.each { |order| order.time_out }
      Order.canceled.each { |order| order.cancel }

      Leftronic.new.clear("shopelia_orders_pending") if Order.where(state_name:"pending").count == 0
      Leftronic.new.clear("shopelia_orders_processing") if Order.where(state_name:"processing").count == 0
		
      status = Order.where(state_name:"pending").count > 0 ? 100 : 0
      Leftronic.new.push_number("shopelia_status", status)			
    end

  end
end
