# -*- encoding : utf-8 -*-
class EbayCom < MerchantHelper
  def initialize(*)
    super
    @availabilities = {
      "Bidding has ended" => false,
      "This listing [hw]as ended" => false,
      "See all results" => false,
    }
  end
end
