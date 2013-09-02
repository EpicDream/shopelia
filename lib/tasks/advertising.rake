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
            link = link.to_s.gsub(/\A.+?(\/dp\/[A-Z0-9]{10}).+\Z/,"http://www.amazon.fr\\1")
            puts "Found link #{link}"
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

      category_names = {
        'pet-supplies'        => 'Animaux',
				'automotive'          => 'Auto et Moto',
        'luggage'             => 'Bagages',
        'jewelry'             => 'Bijoux',
        'hi'                  => 'Bricolage',
        'baby'                => 'Bebe et Puericulture',
        'kitchen'             => 'Cuisine et Maison',
        'dvd'                 => 'DVD et Blu-ray',
        'officeproduct'       => 'Fournitures de bureau',
        'appliances'          => 'Gros electromenager',
        'electronics'         => 'High-tech',
        'hpc'                 => 'Hygiene et Soins du corps',
        'computers'           => 'Informatique',
				'musical-instruments' => 'Instruments de musique',
				'toys'                => 'Jeux et Jouets',
				'videogames'          => 'Jeux video',
				'books'               => 'Livres',
				'english-books'       => 'Livres anglais',
				'software'            => 'Logiciels',
				'lighting'            => 'Luminaires et Eclairage',
				'watch'               => 'Montres',
				'music'               => 'Musique',
				'beauty'              => 'Parfum et Beaute',
        'sports'              => 'Sports et Loisirs',
				'video'               => 'Video',
			}

			bestsellers = YAML::load(File.read("#{Rails.root}/tmp/amazon_bestsellers.yml"))

			category_urls = {}
      products = []

			bestsellers.each_pair do |categ, urls|
				urls.each do |url|
					category_urls[url.unaccent] = category_names[categ]
          products << url
				end
			end

      helpers = Rails.application.routes.named_routes.helpers
      developer = Developer.find_by_name("Prixing")
      xml_data = []
      products.each do |p_url|
				p = Product.find_by_url(p_url)
        unless p.present?
					puts "Cannot find URL #{p_url} with #{amazon_identifier}"
					next
			  end

        p_version = p.product_versions.first

        doc = Nokogiri::HTML(p.description)
        desc = doc.xpath("//text()").to_s.gsub(/\AAmazon.fr/, '').gsub(/\A\s+/,'')

				category = category_urls.has_key?(p.url) ? category_urls[p.url] : 'Shopelia'

        item_data = {
          'product_url' => "https://www.shopelia.com#{Rails.application.routes.url_helpers.gateway_index_path(developer:developer.api_key, tracker:"twenga", url:p.url)}",
          'designation' => p.name,
          'price' => p_version.price,
          'category' => category,
          'image_url' => p.image_url,
          'description' => desc,
          'regular_price' => p_version.price_strikeout || p_version.price,
          'shipping_cost' => p_version.price_shipping,
          'in_stock' => p_version.available ? 'Y' : 'N'
        }

			  xml_data << item_data

      end
      File.open("#{Rails.root}/public/shopelia_stream.xml", 'w') do |f|
			  f.puts xml_data.to_xml(:root => 'catalogue', :children => 'product', :dasherize => false)
			end
    end
  
  end
end
