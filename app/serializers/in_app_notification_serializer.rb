class InAppNotificationSerializer < ActiveModel::Serializer
  attributes :id, :title, :subtitle, :content, :button_title
  attributes :link_kind, :link_identifier, :image_url
  
  def image_url
    Rails.configuration.image_host + object.image.picture.url
  end
  
  def link_kind
    "#{object.resource_klass_name.downcase}s"
  end
  
  def link_identifier
    object.resource_id.to_s
  end
end