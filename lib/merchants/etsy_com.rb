# -*- encoding : utf-8 -*-
class EtsyCom

  AVAILABILITY_HASH = {
    "Informations sur la boutique" => false,
  }

  def initialize url
    @url = url
  end

  def process_shipping_price version
    if version[:price_shipping_text].present?
      text = version[:price_shipping_text].unaccent
      version[:price_shipping_text] = (m = text.match(/France\s+€([\d,\.]+)/) || \
        m = text.match(/Union europeenne\s+€([\d,\.]+)/) || \
        m = text.match(/(?:^|,\s)UE\s+€([\d,\.]+)/) || \
        m = text.match(/Autres pays\s+€([\d,\.]+)/)) ? m[1] : generate_incident(text)
    end
    version
  end

  def process_availability version
    version[:availability_text] = "En stock" if version[:availability_text].blank?
    version
  end

  private

  def generate_incident str
    if str !~ /Etats-Unis/
      Incident.create(
        :issue => "Viking",
        :description => str,
        :resource_type => "Merchant",
        :resource_id => Merchant.find_by_domain("etsy.com").id,
        :severity => Incident::IMPORTANT)
    end
    nil
  end
end
