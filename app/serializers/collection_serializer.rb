class CollectionSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys

  attributes :uuid, :name, :image_url, :tags, :size
  
  def image_url
    Shopelia::Application.config.image_host + object.image.url
  end

  def tags
    object.tags.map(&:name)
  end  
end