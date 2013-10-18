namespace :shopelia do
  namespace :tracking do
    
    desc "Generate request events for all tracked products"
    task :request => :environment do
      developer = Developer.find_by_name("Shopelia")
      Product.joins(:developers).map(&:id).each do |id|
        Event.create(
          :product_id => id,
          :action => Event::REQUEST,
          :developer_id => developer.id)
      end
    end

    desc "Sent XML products feed data for developers"
    task :report => :environment do
      Developer.all.each do |developer|
        products = []
        developer.products.each do |product|
          product_serializer = ProductSerializer.new(product)
          products << product_serializer.as_json
        end
        if products.count > 0
          filename = "/tmp/products-feed-#{SecureRandom.hex(4)}-#{Time.now.strftime("%Y-%m-%d")}.xml"
          File.open(filename, "w") { |file| file.write products.to_xml }
          `gzip #{filename}`
          Emailer.send_products_feed_to_developer(developer, filename + '.gz').deliver
        end
      end
    end
  end
end
