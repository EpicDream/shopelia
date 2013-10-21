namespace :shopelia do
  namespace :customers do
 
    desc "Process batch orders for customers"
    task :batch => :environment do
      CustomersBatchWorker.perform_async
    end
  end
end