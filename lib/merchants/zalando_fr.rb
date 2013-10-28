# -*- encoding : utf-8 -*-
class ZalandoFr

  def initialize url
    @url = url
  end
  
  def process_availability version
    version[:availability_text] = MerchantHelper::UNAVAILABLE if version[:availability_text] =~ /vos modeles preferes/
    version
  end
end