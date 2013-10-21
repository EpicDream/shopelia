namespace :shopelia do
  namespace :customers do
    namespace :cadeau_shaker do 
   
      desc "Process batch orders for Cadeau Shaker"
      task :batch => :environment do
        c = Cutomers::CadeauShaker.new
        c.run
        c.send_email
      end
    end
  end
end