module CartHelper

  def generate_requests_for_current_cart
    EventsWorker.perform_async({
      :ids => Product.where(id:@current_cart.cart_items.map(&:product).map(&:id)).expired.map(&:id),
      :developer_id => @developer.id,
      :action => Event::REQUEST,
      :tracker => "display-cart",
      :device_id => @device.id,
      :ip_address => @remote_ip
    })
  end
end