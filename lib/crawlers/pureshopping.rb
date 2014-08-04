require 'mechanize'
require 'json'

module Crawlers
  class Pureshopping
    BASE_URL = "http://network.moteur-shopping.com"
    LOGIN_URL = "#{BASE_URL}/user/login"
    PRODUCTS_URL = "#{BASE_URL}/default/Catalog/getProducts"
    USERNAME = "ofisch@moteur-shopping-partners"
    PASSWORD = "0F33sch?"
  
    def initialize
      @agent = Mechanize.new
      @agent.idle_timeout = 0.9
    end
  
    def run
      connect
      products
    end
  
    def products
      page = 51
      begin
        response = @agent.post(PRODUCTS_URL, query(page), {"X-Requested-With" => "XMLHttpRequest"})
        body = JSON.parse(response.body)
        data = body["data"]
        created = PureShoppingProduct.create!(data)
        page += 1
        sleep 1
      end until data.empty?
    rescue => e
      Rails.logger.error("[Pureshopping]#{e}")
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
