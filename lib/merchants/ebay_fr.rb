# -*- encoding : utf-8 -*-
class EbayFr < MerchantHelper
  def initialize(*)
    super
    @availabilities = {
      "Les encheres sur cet objet sont terminees" => false,
    }
  end
end
