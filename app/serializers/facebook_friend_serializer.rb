class FacebookFriendSerializer < ActiveModel::Serializer
  attributes :identifier, :name, :picture, :username
end
