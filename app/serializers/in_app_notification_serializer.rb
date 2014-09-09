class InAppNotificationSerializer < ActiveModel::Serializer
  attributes :id, :title, :subtitle, :content, :button_title, :image_url
  
  def image_url
    Rails.configuration.image_host + object.image.picture.url
  end
end