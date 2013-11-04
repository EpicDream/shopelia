class LeftronicLiveProductWorker
  include Sidekiq::Worker

  def perform hash
    time = "#{Time.now.hour}:#{Time.now.min}"
    sleep 5
    product = Product.find(hash["product_id"].to_i)
    Leftronic.new.notify_live_product(product.name, time, product.image_url)
  end
end