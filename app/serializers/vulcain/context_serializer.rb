class Vulcain::ContextSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :session, :account, :order, :user, :answers
  
  def session
    { :uuid => object.uuid, :callback_url => object.callback_url }
  end

  def order
    { :products_urls => object.order_items.map{|item| item.product.url},
      :credentials => object.payment_card ? Vulcain::PaymentCardSerializer.new(object.payment_card).as_json[:payment_card] : nil }
  end
  
  def account
    Vulcain::MerchantAccountSerializer.new(MerchantAccount.find_or_create_by_user_id_and_merchant_id(object.user_id, object.merchant_id)).as_json[:merchant_account]
  end
  
  def user
    Vulcain::UserSerializer.new(object.user, scope:{address_id:object.address_id}).as_json[:user]
  end
  
  def answers
    object.questions.map { |e| { :question_id => e["id"], :answer => e["answer"] } }
  end
  
  def include_order?
    object.questions.size == 0 || object.payment_card.present?
  end
  
  def include_account?
    object.questions.size == 0
  end

  def include_user?
    object.questions.size == 0
  end
  
  def include_answers?
    object.questions.size > 0
  end  
  
end
