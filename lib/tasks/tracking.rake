namespace :shopelia do
  namespace :tracking do
    
    desc "Generate request events for all products tracked or present in collections"
    task :request => :environment do
      tracked_ids = Product.joins(:developers).map(&:id)

      tags = ["__Home"].map{|n| Tag.find_or_create_by_name(n)}
      collections = tags.map{|tag| tag.collections.public}.inject(:&) || []
      collections_ids = CollectionItem.where(collection_id:collections.map(&:id)).select("distinct product_id").map(&:product_id)
      
      developer = Developer.find_by_name("Shopelia")
      (tracked_ids + collections_ids).uniq.each do |id|
        Event.create(
          :product_id => id,
          :action => Event::REQUEST,
          :developer_id => developer.id)
        sleep 2
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
          if (developer.name == "CadeauShaker")
            filename = "/tmp/products-feed.xml"
            File.open(filename, "w") { |file| file.write products.to_xml }
            Customers::CadeauShaker.upload_file(filename)
			    else
            filename = "/tmp/products-feed-#{SecureRandom.hex(4)}-#{Time.now.strftime("%Y-%m-%d")}.xml"
            File.open(filename, "w") { |file| file.write products.to_xml }
            `gzip #{filename}`
            Emailer.send_products_feed_to_developer(developer, filename + '.gz').deliver
          end
        end
      end
    end
  end
end
