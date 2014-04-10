class LookImageSerializer < ActiveModel::Serializer
  attributes :id, :small, :large, :medium

  def small
    image_with_format(:pico)
  end

  def large
    image_with_format(:large)
  end
  
  def medium
    image_with_format(:small)
  end
  
  private
  
  def image_with_format format
    { url: Rails.configuration.image_host + object.picture.url(format),
      size: JSON.parse(object.picture_sizes || "{}")[format.to_s] }
  end
end