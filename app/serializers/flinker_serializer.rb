class FlinkerSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :email, :username
end