class LeftronicLiveProductWorker
  include Sidekiq::Worker

  def perform hash
    time = Time.now.strftime("%H:%M")
    product = Product.find(hash["product_id"].to_i)
    if product.versions_expired?     
      sleep 5
      product = Product.find(hash["product_id"].to_i)
    end
    Leftronic.new.notify_live_product(product.name, time, product.image_url) unless product.name.nil?
  end
end