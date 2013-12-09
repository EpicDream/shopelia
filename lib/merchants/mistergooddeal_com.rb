# -*- encoding : utf-8 -*-
class MistergooddealCom < MerchantHelper
  def initialize(*)
    super
    @availabilities = {
      /\d+ produits/i => false,
    }
  end
end
