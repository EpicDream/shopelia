module Vulcain

  class ProductInformations < Vulcain::Ressource

    def self.create data
      post_request("product_informations", data)
    end
    
    def self.generate_versions product
      result = Vulcain::ProductInformations.create({
        "vendor" => product.merchant.vendor,
        "context" => { "url" => product.url }
      })
      product.update_attributes(
        :name => result["product_title"],
        :image_url => result["product_image_url"],
        :description => result["description"],
        :versions_expires_at => 4.hours.from_now
      )
      version = product.product_versions.first
      version = ProductVersion.create(product:product) if version.nil?
      version.update_attributes(
        :price => result["product_price"],
        :price_shipping => result["shipping_price"],
        :price_strikeout => result["price_strikeout"],
        :shipping_info => result["shipping_info"]
      )
    end
    
  end
end
