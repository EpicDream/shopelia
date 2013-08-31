class Vulcain::ContextSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :session, :account, :order, :user, :answers
  
  def session
    { :uuid => object.uuid, :callback_url => object.callback_url }
  end

  def order
    if object.cvd_solution.nil?
      credentials = Vulcain::PaymentCardSerializer.new(object.meta_order.payment_card).as_json[:payment_card]
    elsif object.cvd_solution == "amazon" && object.payment_transaction.present?
      credentials = { :voucher => object.payment_transaction.mangopay_amazon_voucher_code }
    else
      credentials = nil
    end
    { :products_urls => object.order_items.map{|item| Linker.monetize(item.product.url)},
      :products => object.order_items.map{|item| { :url => Linker.monetize(item.product_version.product.url), 
                                                   :quantity => item.quantity, 
                                                   :id => item.product_version_id }},
      :credentials => credentials
    }
  end
  
  def account
    Vulcain::MerchantAccountSerializer.new(object.merchant_account).as_json[:merchant_account]
  end
  
  def user
    Vulcain::UserSerializer.new(object.user, scope:{address_id:object.meta_order.address_id}).as_json[:user]
  end
  
  def answers
    object.questions.map { |e| { :question_id => e["id"], :answer => e["answer"] } }
  end
  
  def include_answers?
    object.questions.size > 0
  end  
end
