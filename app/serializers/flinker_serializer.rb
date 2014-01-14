class FlinkerSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :email, :username, :avatar, :country, :follows_count, :looks_count, :likes_count, :staff_pick

  def staff_pick
    object.staff_pick ? 1 : 0
  end

  def name
    object.name.try(:strip)
  end

  def country
    object.country.try(:iso)
  end

  def avatar
    Rails.configuration.host + object.avatar.url(:thumb)
  end
end