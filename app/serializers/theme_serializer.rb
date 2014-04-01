class ThemeSerializer < ActiveModel::Serializer
  attributes :id, :title, :subtitle, :position, :cover_height, :cover, :country
  attributes :looks, :flinkers
  
  def cover
    {small: cover_with_format(:pico), large: cover_with_format(:large)}
  end
  
  def country
    object.countries.first.iso
  end
  
  def looks
    ActiveModel::ArraySerializer.new(object.looks).as_json
  end
  
  def flinkers
    ActiveModel::ArraySerializer.new(object.flinkers).as_json
  end
  
  def include_country?
    object.countries.first.present?
  end
  
  def include_looks?
    scope && scope[:full] && object.looks.any?
  end

  def include_flinkers?
    scope && scope[:full] && object.flinkers.any?
  end
  
  private
  
  def cover_with_format format
    Rails.configuration.image_host + object.theme_cover.picture.url(format, timestamp:true)
  end
  
end