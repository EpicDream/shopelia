class LeetchiCardWorker
  include SuckerPunch::Worker

  def perform(card)
    ActiveRecord::Base.connection_pool.with_connection do
      card.create_leetchi
    end
  end
end
