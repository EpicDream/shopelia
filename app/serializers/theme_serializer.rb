class ThemeSerializer < ActiveModel::Serializer
  attributes :title, :subtitle, :position, :cover_height, :cover
  
  def cover
    Rails.configuration.image_host + object.theme_cover.picture.url(:large, timestamp:true)
  end
  
  def hashtags
    []
  end
  
  def include_hashtags?
    scope && scope[:complete]
  end
  
end