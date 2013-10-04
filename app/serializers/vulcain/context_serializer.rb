class Vulcain::ContextSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :session, :account, :order, :user, :answers
  
  def session
    { :uuid => object.uuid, :callback_url => object.callback_url }
  end

  def order
    if object.cvd_solution.nil?
      credentials = Vulcain::PaymentCardSerializer.new(object.meta_order.payment_card).as_json[:payment_card]
    elsif object.cvd_solution == "amazon" 
      if object.payment_transaction.present?
        credentials = { :voucher => object.payment_transaction.mangopay_amazon_voucher_code }
      else
        credentials = { :number => "", :exp_date => "", :exp_year => "", :cvv => "", :holder => "" }
      end
    else
      credentials = nil
    end
    { :products_urls => object.order_items.map{|item| Linker.monetize(item.product.url)},
      :products => ActiveModel::ArraySerializer.new(object.order_items).as_json,
      :credentials => credentials,
      :gift_message => object.gift_message
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
