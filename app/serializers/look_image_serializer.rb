class LookImageSerializer < ActiveModel::Serializer
  attributes :id, :w160, :w320, :w640

  def w160
    { url: Rails.configuration.host + object.picture.url(:w160),
      size: JSON.parse(object.picture_sizes)["w160"] }
  end

  def w320
    { url: Rails.configuration.host + object.picture.url(:w320),
      size: JSON.parse(object.picture_sizes)["w320"] }
  end

  def w640
    { url: Rails.configuration.host + object.picture.url(:w640),
      size: JSON.parse(object.picture_sizes)["w640"] }
  end
end