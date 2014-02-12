class FacebookFriendSerializer < ActiveModel::Serializer
  attributes :identifier, :name, :picture
end
