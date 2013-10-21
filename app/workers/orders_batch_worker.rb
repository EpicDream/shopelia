class OrdersBatchWorker
  include Sidekiq::Worker

  def perform
    Order.queued.each do |order|
      order.start_from_queue if !order.queue_busy?
    end
  end
end