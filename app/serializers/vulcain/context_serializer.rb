class Vulcain::ContextSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :session, :account, :order, :user
  
  def session
    { :uuid => object.uuid, :callback_url => object.callback_url }
  end

  def order
    { :products_urls => [ object.product.url ] }
  end
  
  def account
    Vulcain::MerchantAccountSerializer.new(MerchantAccount.find_or_create(object.user, object.merchant)).as_json[:merchant_account]
  end
  
  def user
    Vulcain::UserSerializer.new(object.user).as_json[:user]
  end
end
