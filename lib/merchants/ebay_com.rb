# -*- encoding : utf-8 -*-
class EbayCom < MerchantHelper
  def initialize(*)
    super
    @availabilities = {
      "Bidding has ended" => false,
      "This listing has ended" => false,
    }
  end
end
