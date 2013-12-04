class LookImageSerializer < ActiveModel::Serializer
  attributes :id, :w160, :w320, :w640

  def w160
    Rails.configuration.host + object.picture.url(:w160)
  end

  def w320
    Rails.configuration.host + object.picture.url(:w320)
  end

  def w640
    Rails.configuration.host + object.picture.url(:w640)
  end
end