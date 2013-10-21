class CustomersBatchWorker
  require 'customers/cadeau_shaker'
  include Sidekiq::Worker

  def perform
    Customers::CadeauShaker.run
  end
end