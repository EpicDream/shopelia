class MerkavWorker
  include Sidekiq::Worker

  def perform hash
    transaction = MerkavTransaction.find(hash["merkav_transaction_id"])
    merkav = Customers::Merkav.new(transaction)
    merkav.run
  rescue 
  end
end