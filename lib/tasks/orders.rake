namespace :shopelia do
  namespace :orders do
    
    desc "Manage orders life cycle"
    task :clean => :environment do
      Order.delayed.each { |order| order.notify_creation }
      Order.expired.each { |order| order.time_out }
      Order.canceled.each { |order| order.cancel }
    end

  end
end
