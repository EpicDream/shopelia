class LookSerializer < ActiveModel::Serializer
  attributes :uuid, :name, :url, :published_at, :flinker, :products, :images
  
  def published_at
    object.published_at.to_i
  end

  def flinker
    FlinkerSerializer.new(object.flinker).as_json[:flinker]
  end

  def products
    ActiveModel::ArraySerializer.new(object.products).as_json
  end

  def images
    ActiveModel::ArraySerializer.new(object.look_images).as_json
  end
end