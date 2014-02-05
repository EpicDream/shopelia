class LookSerializer < ActiveModel::Serializer
  attributes :uuid, :name, :url, :published_at, :flinker, :products, :images, :liked, :description
  attributes :is_published_updated_at, :updated_at
  
  def name
    object.name.try(:strip)
  end

  def published_at
    object.published_at.to_i
  end
  
  def updated_at
    object.updated_at.to_i
  end
  
  def is_published_updated_at
    object.is_published_updated_at.to_i
  end

  def flinker
    FlinkerSerializer.new(object.flinker).as_json[:flinker]
  end

  def products
    object.look_products.map do |lp|
      if lp.product.present? && lp.product.available?
        { code: lp.code.blank? ? "" : I18n.t("flink.products." + lp.code),
          product: ProductSerializer.new(lp.product, scope:scope).as_json[:product] }
      elsif lp.brand.present?
        { code: lp.code.blank? ? "" : I18n.t("flink.products." + lp.code),
          brand: lp.brand }
      end
    end.compact
  end

  def images
    ActiveModel::ArraySerializer.new(object.look_images.order(:display_order)).as_json
  end

  def liked
    object.liked_by?(scope[:flinker]) ? 1 : 0
  end

  def include_liked?
    scope.present? && scope[:flinker].present?
  end
end
