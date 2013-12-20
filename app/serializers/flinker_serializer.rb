class FlinkerSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :email, :username, :avatar, :country

  def country
    object.country.try(:iso)
  end

  def avatar
    Rails.configuration.host + object.avatar.url(:thumb)
  end
end