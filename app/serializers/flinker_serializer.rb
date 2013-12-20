class FlinkerSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :email, :username, :avatar

  def avatar
    object.avatar.url(:thumb)
  end
end