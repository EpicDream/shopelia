require 'mechanize'
require 'json'

module Crawlers
  class Pureshopping
    BASE_URL = "http://network.moteur-shopping.com"
    LOGIN_URL = "#{BASE_URL}/user/login"
    PRODUCTS_URL = "#{BASE_URL}/default/Catalog/getProducts"
    CATEGORIES_URL = "#{BASE_URL}/default/catalog/getCategoriesList/"
    USERNAME = "ofisch@moteur-shopping-partners"
    PASSWORD = "0F33sch?"
    CATEGORIES = ['Femme > Vêtements > Short','Femme > Vêtements > Gilet','Femme > Vêtements > Jean','Femme > Vêtements > Jupe','Femme > Vêtements > Legging','Femme > Vêtements > Maillot de bain','Femme > Vêtements > Manteau','Femme > Vêtements > Pantalon','Femme > Vêtements > Pull','Femme > Vêtements > Robe','Femme > Vêtements > Short','Femme > Vêtements > Top','Femme > Vêtements > Veste','Femme > Accessoires > Ceinture','Femme > Accessoires > Chapeaux et bonnets','Femme > Accessoires > Echarpes et foulards','Femme > Accessoires > Gants','Femme > Accessoires > Lunettes > Lunettes de soleil','Femme > Accessoires > Pochette','Femme > Accessoires > Sac','Femme > Accessoires > Bijoux > Accessoire Cheveux','Femme > Accessoires > Bijoux > Bague fantaisie','Femme > Accessoires > Bijoux > Bague joaillerie',"Femme > Accessoires > Bijoux > Boucles d'oreilles",'Femme > Accessoires > Bijoux > Bracelet','Femme > Accessoires > Bijoux > Broche','Femme > Accessoires > Bijoux > Collier','Femme > Accessoires > Bijoux > Montre','Femme > Chaussures > Tongs','Femme > Chaussures > Sandales','Femme > Chaussures > Mocassins','Femme > Chaussures > Escarpins','Femme > Chaussures > Derbies','Femme > Chaussures > Bottes et bottines','Femme > Chaussures > Baskets','Femme > Chaussures > Ballerines','Femme > Sport','Femme > Lingerie']
    CATEGORIES_YAML_FILE_PATH = "#{Rails.root}/lib/crawlers/pureshopping/categories.yml"
     
    def initialize
      @agent = Mechanize.new
      @agent.idle_timeout = 0.9
      @agent.max_history = 0
      @agent.agent.http.retry_change_requests = true
    end
  
    def run
      connect
      products
    end
  
    def products
      page = 0
      begin
        response = @agent.post(PRODUCTS_URL, query(page), {"X-Requested-With" => "XMLHttpRequest"})
        body = JSON.parse(response.body)
        data = body["data"]
        PureShoppingProduct.create!(data)
        page += 1
        sleep 5
      end until data.empty?
    rescue => e
      Rails.logger.error("[Pureshopping]#{e}")
    end
    
    def categories
      connect
      mapping = {}
      CATEGORIES.each do |keywords|
        keyword = keywords.split(/>/).last.strip
        response = @agent.post(CATEGORIES_URL, { keyword:keyword, __site_id:19 }, {"X-Requested-With" => "XMLHttpRequest"})
        categories = JSON.parse(response.body)
        categories = categories.each do |category|
          next unless CATEGORIES.include?(category["caption"])
          mapping[category["value"]] = category["caption"].unaccent
        end
      end
      File.open(CATEGORIES_YAML_FILE_PATH, "w") { |f| p mapping;YAML.dump(mapping, f) }
    end
  
    def connect
      response = @agent.post(LOGIN_URL, { login: USERNAME, password: PASSWORD })
      body = JSON.parse(response.body)
      raise "Unable to connect" unless body["success"]
    end
  
    private
  
    def query page=0
      start = page * 1000 
      { partner_cpc_min: 0.19, start:start, limit:1000, single_product_select:false, category:1, __site_id:19}
    end
  end
end
