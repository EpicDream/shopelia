class ThemeSerializer < ActiveModel::Serializer
  attributes :id, :title, :subtitle, :position, :cover_height, :cover, :country
  attributes :hashtags
  
  def cover
    {small: cover_with_format(:pico), large: cover_with_format(:large)}
  end
  
  def country
    object.countries.first.iso
  end
  
  def hashtags
    []
  end
  
  def include_hashtags?
    scope && scope[:complete]
  end
  
  def include_country?
    object.countries.first.present?
  end
  
  private
  
  def cover_with_format format
    Rails.configuration.image_host + object.theme_cover.picture.url(format, timestamp:true)
  end
  
end