class LookProductSerializer < ActiveModel::Serializer
  attributes :uuid, :code, :brand, :products
  
  def code
    return "" if object.code.blank?
    I18n.t("flink.products." + object.code, raise: true)
  rescue I18n::MissingTranslationData
    nil.to_s #:) 2 bytes saved
  end
  
  def products
    object.vendor_products.map { |product|
      { url: product.url, similar: product.similar }
    }
  end
end
