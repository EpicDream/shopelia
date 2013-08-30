namespace :shopelia do
  namespace :advertising do
    
    desc "Create batch events for Amazon top-sellers"
    task :amazon_best => :environment do

      skipped_categories = ['mobile-apps', 'gift-cards', 'digital-text', 'dmusic', 'shoes', 'apparel']

      categories_urls = {}
      product_urls = {}
      uri = URI('http://www.amazon.fr/gp/bestsellers')
      bestsellers = Net::HTTP.get(uri)
      n = Nokogiri::HTML(bestsellers)
      categories = n.css('ul#zg_browseRoot li')
      categories.each do |categ|
        link = categ.css('a')
        link = link.to_s.gsub(/\A.+?"/,'').gsub(/".+\Z/,'')
        next unless link =~ /\S/
        categ_name = link.gsub(/\A.+\//, '')
        next if skipped_categories.include?(categ_name)
        categories_urls[categ_name] = link
      end

      categories_urls.each_pair do |categ_name, category_url|
        (1..5).each do |p|
          uri = URI("#{category_url}?pg=#{p}")
          puts "Fetching #{uri}"
          items_list = Net::HTTP.get(uri)
          n = Nokogiri::HTML(items_list)
          links = n.css('div.zg_title a')
          links.each do |link|
            link = URI.unescape(link.to_s.gsub(/\A.+?"/,'').gsub(/".+\Z/,''))
            link.chomp!
            product_urls[categ_name] = [] unless product_urls.has_key?(categ_name)
            product_urls[categ_name] << link if link =~ /\S/
            Event.create!(:url => link, :action => Event::REQUEST, :developer_id => 1, :device_id => 1)
          end
        end
      end

      File.open("#{Rails.root}/tmp/amazon_bestsellers.yml", 'w') do |f|
        f.puts YAML::dump(product_urls)
      end
    end

    desc "Generate twenga XML file"
    task :twenga => :environment do

			category_urls = YAML::load(File.read("#{Rails.root}/tmp/amazon_bestsellers.yml"))

      category_names = {
        'pet-supplies' => 'Animaux'
			}


      helpers = Rails.application.routes.named_routes.helpers
      developer = Developer.find_by_name("Prixing")
      xml_data = []
      Product.where("merchant_id = 2 and viking_failure = false and now() - created_at < interval '24 hours'").each  do |p|
        p_version = p.product_versions.first

        doc = Nokogiri::HTML(p.description)
        desc = doc.xpath("//text()").to_s.gsub(/\AAmazon.fr/, '').gsub(/\A\s+/,'')

        item_data = {
          'product_url' => "https://www.shopelia.com#{Rails.application.routes.url_helpers.gateway_index_path(developer:developer.api_key, tracker:"twenga", url:p.url)}",
          'designation' => p.name,
          'price' => p_version.price,
          'category' => 'Shopelia',
          'image_url' => p.image_url,
          'description' => desc,
          'regular_price' => p_version.price_strikeout || p_version.price,
          'shipping_cost' => p_version.price_shipping,
          'in_stock' => p_version.available ? 'Y' : 'N'
        }

			  xml_data << item_data

      end
			puts xml_data.to_xml(:root => 'catalogue', :children => 'product', :dasherize => false)
    end
  
  end
end
