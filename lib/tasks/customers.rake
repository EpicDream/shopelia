namespace :shopelia do
  namespace :customers do
    namespace :cadeau_shaker do
      require 'customers/cadeau_shaker'
 
      desc "Process batch orders for Cadeau Shaker"
      task :batch => :environment do
        c = Customers::CadeauShaker.new
        c.run
        c.send_email
      end
    end
  end
end
