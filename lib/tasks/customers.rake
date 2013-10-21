namespace :shopelia do
  namespace :customers do
 
    desc "Process batch orders for customers"
    task :batch => :environment do
      Customers::CadeauShaker.run
    end
  end
end