module CollectionHelper

  def generate_requests_for_current_collection
    Product.where(id:@collection.reload.collection_items.map(&:product_id)).expired.map(&:id).each do |id|
      EventsWorker.perform_async({
        :product_id => id,
        :developer_id => @developer.id,
        :action => Event::REQUEST,
        :tracker => "display-collection",
        :device_id => @device.id,
        :ip_address => @remote_ip
      })
    end
    @collection.products.each do |product|
      product.authorize_push_channel
    end
  end
end