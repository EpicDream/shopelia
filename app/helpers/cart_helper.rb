module CartHelper

  def generate_requests_for_current_cart
    Product.where(id:@current_cart.cart_items.map(&:product).map(&:id)).expired.map(&:id).each do |id|
      EventsWorker.perform_async({
        :product_id => id,
        :developer_id => @developer.id,
        :action => Event::REQUEST,
        :tracker => "display-cart",
        :device_id => @device.id,
        :ip_address => @remote_ip
      })
    end
  end
end