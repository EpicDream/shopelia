module Customers
  class CadeauShaker
    
    ORDERS_URL = "http://www.cadeaushaker.fr/commande.php?source=shopelia"
    ACCOUNT_EMAIL = "service-client@cadeaushaker.fr"
    DEVELOPER_NAME = "CadeauShaker"

    def initialize
      @user = User.find_by_email!(ACCOUNT_EMAIL)
      @developer = Developer.find_by_name!(DEVELOPER_NAME)
      @card = @user.payment_cards.first!
      @tracker = "batch"
    end
    
    def run
      content = fetch(ORDERS_URL)
      orders = extract_orders(content)
      
      log = []
      orders.each do |order|
        log << self.process_order(order)
      end
    end

    def fetch url
      uri = URI.parse url
      Net::HTTP.get uri.host, uri.request_uri
    end
    
    def extract_orders content
      Hash.from_xml(content)["commandes"]["commande"]
    end
    
    def build_uuid id
      uuid = "cadeaushaker#{id}"
      uuid + "x" * (32 - uuid.length)
    end
    
    def build_address hash
      hash["address2"] = nil if hash["address2"] == "."
      Address.create(
        user_id:@user.id,
        first_name:hash["first_name"],
        last_name:hash["last_name"],
        address1:hash["address"],
        address2:hash["address2"],
        zip:hash["zip"],
        city:hash["city"],
        country_iso:hash["country_iso"],
        phone:hash["telephone"])
    end
    
    def process_order hash
      uuid = build_uuid(hash["id_commande"])
      return if Order.find_by_uuid(uuid).present?
      
      product_version = ProductVersion.find_by_id(hash["product_version_id"])
      return "Impossible to find product version id #{hash["product_version_id"]} for order #{hash["id_commande"]}" if product_version.nil?
      
      return "Invalid expected price total for order #{hash["id_commande"]}" unless hash["expected_price_total"].to_f > 0
      return "Gift message required for order #{hash["id_commande"]}" if hash["gift_message"].blank?
      
      return "Only French address are accepted (order #{hash["id_commande"]})" if hash["country_iso"] != "fr"
      return "Missing name for address (order #{hash["id_commande"]})" if hash["first_name"].nil? || hash["last_name"].nil?
      
      address = build_address(hash)
      return "Invalid address for order #{hash["id_commande"]} - #{address.errors.full_messages.join(",")}" if address.errors.any?
      
      order = Order.new(
        uuid:uuid,
        user_id:@user.id,
        developer_id:@developer.id,
        tracker:@tracker,
        address_id: address.id,
        card_id: @card.id,
        products: { product_version_id:product_version.id },
        state_name: "queued",
        gift_message:hash["gift_message"],
        expected_price_total:hash["expected_price_total"].to_f)
      if order.save
        "Order #{hash["id_commande"]} for product #{product_version.name} successfully queued for processing"
      else
        "Cannot create order #{hash["id_commande"]} - #{order.errors.full_messages.join(",")}"
      end
    end
  end
end
