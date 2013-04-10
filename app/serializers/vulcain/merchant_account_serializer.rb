class Vulcain::MerchantAccountSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :login, :password, :new_account
  
  def new_account
    object.merchant_created? ? nil : true
  end
end
