class LookSerializer < ActiveModel::Serializer
  attributes :uuid, :name, :url, :published_at, :flinker, :products, :images
  
  def published_at
    object.published_at.to_i
  end

  def flinker
    FlinkerSerializer.new(object.flinker).as_json[:flinker]
  end

  def products
    object.products.map{ |p| ProductSerializer.new(p, scope:scope).as_json[:product] if p.available? }.compact
  end

  def images
    ActiveModel::ArraySerializer.new(object.look_images.order(:display_order)).as_json
  end
end