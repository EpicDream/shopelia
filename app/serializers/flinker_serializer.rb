class FlinkerSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :email, :username, :avatar, :country

  def name
    object.name.strip
  end

  def country
    object.country.try(:iso)
  end

  def avatar
    Rails.configuration.host + object.avatar.url(:thumb)
  end
end