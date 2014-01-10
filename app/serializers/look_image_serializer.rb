class LookImageSerializer < ActiveModel::Serializer
  attributes :id, :small, :large

  def small
    { url: Rails.configuration.host + object.picture.url(:pico),
      size: JSON.parse(object.picture_sizes || "{}")["pico"] }
  end

  def large
    { url: Rails.configuration.host + object.picture.url(:large),
      size: JSON.parse(object.picture_sizes || "{}")["large"] }
  end
end