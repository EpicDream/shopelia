class ThemeSerializer < ActiveModel::Serializer
  attributes :title, :subtitle, :position, :cover_height, :cover, :country
  
  def cover
    Rails.configuration.image_host + object.theme_cover.picture.url(:large, timestamp:true)
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
  
end