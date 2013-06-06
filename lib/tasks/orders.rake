namespace :shopelia do
  namespace :orders do
    
    desc "Time out orders and send delayed notifications"
    task :clean => :environment do
      Order.delayed.each { |order| order.notify_creation }
      Order.expired.each { |order| order.time_out }
    end

  end
end
