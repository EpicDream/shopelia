class LeetchiUserWorker
  include SuckerPunch::Worker

  def perform(user)
    ActiveRecord::Base.connection_pool.with_connection do
      user.create_leetchi
    end
  end
end
