class LeftronicLiveProductWorker
  include Sidekiq::Worker

  def perform hash
    time = "#{Time.now.hour}:#{Time.now.min}"
    product = Product.find(hash["product_id"].to_i)
    if product.versions_expired?     
      sleep 5
      product = Product.find(hash["product_id"].to_i)
    end
    Leftronic.new.notify_live_product(product.name, time, product.image_url)
  end
end