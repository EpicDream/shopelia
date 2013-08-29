namespace :shopelia do
  namespace :advertising do
    
    desc "Create batch events for Amazon top-sellers"
    task :amazon_best => :environment do

      categories_urls = []
      product_urls = []
      uri = URI('http://www.amazon.fr/gp/bestsellers')
      bestsellers = Net::HTTP.get(uri)
      n = Nokogiri::HTML(bestsellers)
      categories = n.css('ul#zg_browseRoot li')
      categories.each do |categ|
        link = categ.css('a')
        link = link.to_s.gsub(/\A.+?"/,'').gsub(/".+\Z/,'')
        categories_urls << link if link =~ /\S/
      end

      categories_urls.each do |category_url|
        (1..5).each do |p|
          uri = URI("#{category_url}?pg=#{p}")
          puts "Fetching #{uri}"
          items_list = Net::HTTP.get(uri)
          n = Nokogiri::HTML(items_list)
          links = n.css('div.zg_title a')
          links.each do |link|
            link = URI.unescape(link.to_s.gsub(/\A.+?"/,'').gsub(/".+\Z/,''))
            product_urls << link if link =~ /\S/
            Event.create(:url => link, :action => Event::REQUEST, :developer_id => 1)
          end
          File.open("#{Rails.root}/tmp/amazon_bestsellers.txt", 'w') do |f|
            f.puts product_urls.join('')
          end
          exit
        end
      end
    end
  
  end
end
