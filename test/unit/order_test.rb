# -*- encoding : utf-8 -*-
require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  fixtures :users, :products, :merchants, :orders, :payment_cards, :order_items, :addresses, :merchant_accounts
  
  setup do
    @user = users(:elarch)
    @product = products(:usbkey)
    @order = orders(:elarch_rueducommerce)
    @card = payment_cards(:elarch_hsbc)
    @address = addresses(:elarch_neuilly) 
  end

  test "it should create order" do
    order = Order.create(
      :user_id => @user.id,
      :payment_card_id => @card.id,
      :products => [ {
        :url => "http://www.amazon.fr/Brother-Télécopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO",
        :name => "Papier normal Fax T102 Brother FAXT102G1",
        :image_url => "http://www.prixing.fr/images/product_images/2cf/2cfb0448418dc3f9f3fc517ab20c9631.jpg" } ],
      :address_id => @address.id,
      :expected_price_total => 100)
    assert order.persisted?, order.errors.full_messages.join(",")
    assert_equal :processing, order.state
    assert order.merchant_account.present?
    assert order.uuid.present?
    assert_equal 1, order.reload.order_items.count
    
    product = order.order_items.first.product
    assert_equal "http://www.amazon.fr/Brother-Telecopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=shopelia-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO", product.url
    assert_equal "Papier normal Fax T102 Brother FAXT102G1", product.name
    assert_equal "http://www.prixing.fr/images/product_images/2cf/2cfb0448418dc3f9f3fc517ab20c9631.jpg", product.image_url
  end
  
  test "it should send email if notification is requested" do
    @order.notify_creation
    
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "a notification email should have been sent"
    assert_match /Rue du Commerce/, mail.decoded
    
    assert @order.reload.notification_email_sent_at.present?
  end
  
  test "it shouldn't send notification email if already sent" do
    @order.update_attribute :notification_email_sent_at, Time.now
    @order.notify_creation
    assert ActionMailer::Base.deliveries.last.nil?
  end

  test "it should create order with specific address" do
    assert_difference('MerchantAccount.count', 1) do
      order = Order.new(
        :user_id => @user.id,
        :expected_price_total => 100,
        :payment_card_id => @card.id,
        :products => [ {
          :url => "http://www.rueducommerce.fr/productA",
          :name => "Product A",
          :image_url => "http://www.rueducommerce.fr/logo.jpg" } ],        
        :address_id => addresses(:elarch_vignoux).id)
      assert order.save, order.errors.full_messages.join(",")
    end
  end

  test "it shouldn't create order without address specified" do
    order = Order.new(
      :user_id => @user.id, 
      :expected_price_total => 100,
      :products => [ {
        :url => "http://www.rueducommerce.fr/productA",
        :name => "Product A",
        :image_url => "http://www.rueducommerce.fr/logo.jpg" } ],        
      :payment_card_id => @card.id)
    assert !order.save, "Order shouldn't have saved"
    assert_equal "L'adresse doit être renseignée", order.errors.full_messages.first
    mail = ActionMailer::Base.deliveries.last
    assert !mail.present?, "a notification email shouldn't have been sent"
  end

  test "it shouldn't create order without payment_card specified" do
    order = Order.new(
      :user_id => @user.id, 
      :expected_price_total => 100,
      :products => [ {
        :url => "http://www.rueducommerce.fr/productA",
        :name => "Product A",
        :image_url => "http://www.rueducommerce.fr/logo.jpg" } ],        
      :address_id => @address.id)
    assert !order.save, "Order shouldn't have saved"
    assert_equal "Le moyen de paiement doit être renseigné", order.errors.full_messages.first
  end

  test "it shouldn't accept urls from different merchants" do
    order = Order.create(
      :user_id => @user.id,
      :payment_card_id => @card.id,
      :address_id => @address.id,
      :expected_price_total => 100,
      :products => [ 
        { :url => "http://www.rueducommerce.fr/productA",
          :name => "Product A",
          :image_url => "http://www.rueducommerce.fr/logo.jpg" },
        { :url => "http://www.amazon.fr/productA",
          :name => "Product B",
          :image_url => "http://www.amazon.fr/logo.jpg" }        
        ]
      )
    assert !order.persisted?, "Order should have been destroyed"
    mail = ActionMailer::Base.deliveries.last
    assert !mail.present?, "a notification email shouldn't have been sent"
  end
  
  test "it shouldn't create order without products" do
    order = Order.new(
      :user_id => @user.id, 
      :expected_price_total => 100,
      :address_id => @address.id,
      :payment_card_id => @card.id)
    assert !order.save, "Order shouldn't have saved"
    assert_equal I18n.t('orders.errors.no_product'), order.errors.full_messages.first
  end

  test "it shouldn't create order with invalid product" do
    order = Order.create(
      :user_id => @user.id, 
      :expected_price_total => 100,
      :address_id => @address.id,
      :products => [ { :invalid => "http://www.rueducommerce.fr/productA" } ],              
      :payment_card_id => @card.id)
    assert !order.persisted?, "Order shouldn't have saved"
    assert_equal I18n.t('orders.errors.invalid_product', :error => ''), order.errors.full_messages.first
  end
  
  test "it should monetize urls" do
    order = Order.new(
      :user_id => @user.id,
      :payment_card_id => @card.id,
      :products => [ {
        :url => "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY",
        :name => "Aladdin",
        :image_url => "http://www.amazon.fr/logo.jpg" } ],
      :address_id => @address.id,
      :expected_price_total => 100)
    assert order.save
    assert_equal 1, order.reload.order_items.count
    assert_equal "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=shopelia-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY", order.order_items.first.product.url
  end
  
  test "it should set message" do
    @order.process "message", { "message" => "bla" }
    
    assert_equal "bla", @order.message
  end
  
  test "it should start order" do
    start_order
    
    assert_equal :preparing, @order.reload.state
  end
  
  test "it shouldn't start order if missing address" do
    @order.address_id = nil
    start_order
    
    assert_equal :initialized, @order.state
  end

  test "it shouldn't start order if missing payment card" do
    @order.payment_card_id = nil
    start_order
    
    assert_equal :initialized, @order.state
  end

  test "it shouldn't start order if missing merchant account" do
    @order.merchant_account_id = nil
    start_order
    
    assert_equal :initialized, @order.state
  end
  
  test "it shouldn't start order if missing order items" do
    @order.order_items.destroy_all
    start_order
    
    assert_equal :initialized, @order.state
  end
  
  test "it should fail order if out of stock" do
    start_order
    callback_order "failure", { "status" => "out_of_stock" }
    
    assert_equal :failed, @order.state
    assert_equal "out_of_stock", @order.error_code
  end
  
  test "it should pause order with vulcain exception" do
    start_order
    calback_order "failure", { "status" => "exception" }
    
    assert_equal :pending, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "exception", @order.message
  end

  test "it should pause order with vulcain error" do
    start_order
    callback_order "failure", { "status" => "error" }
    
    assert_equal :pending, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "error", @order.message    
  end
  
  test "it should pause order with vulcain no_idle" do
    start_order
    callback_order "failure", { "status" => "no_idle" }
    
    assert_equal :pending, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "no_idle", @order.message
  end

  test "it should pause order with vulcain driver problem" do
    start_order
    callback_order "failure", { "status" => "driver_failed" }
    
    assert_equal :pending, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "driver_failed", @order.message
  end

  test "it should pause order with vulcain time out" do
    start_order
    callback_order "failure", { "status" => "order_timeout" }
    
    assert_equal :pending, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "order_timeout", @order.message
  end

  test "it should pause order with vulcain dispatcher crash" do
    start_order
    callback_order "failure", { "status" => "dispatcher_crash" }
    
    assert_equal :pending, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "dispatcher_crash", @order.message
  end

  test "it should pause order with vulcain uuid conflict" do
    start_order
    callback_order "failure", { "status" => "uuid_conflict" }
    
    assert_equal :pending, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "uuid_conflict", @order.message
  end

  test "it should pause order with vulcain product not found" do
    start_order
    callback_order "failure", { "status" => "no_product_available" }
    
    assert_equal :pending, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "product_not_found", @order.message
  end  

  test "it should restart paused order" do
    pause_order
    start_order
    
    assert :preparing, @order.state
  end
  
  test "it should time out paused order" do
    pause_order
    time_out_order
    
    assert :failed, @order.state
    assert "shopelia", @order.error_code
    assert "timed_out", @order.message
  end
  
  test "it should cancel paused order" do
    pause_order
    cancel_order
    
    assert :failed, @order.reload.state
    assert "shopelia", @order.error_code
    assert "canceled", @order.message
  end
  
  test "it should update order when assessing" do
    start_order
    assess_order
    
    assert_equal 16, @order.prepared_price_total
    assert_equal 14, @order.prepared_price_product
    assert_equal 2, @order.prepared_price_shipping
    assert_equal 1, @order.questions.count
    assert_equal "3", @order.questions.first["id"]
    
    item = @order.order_items.where(:product_id => products(:usbkey).id).first
    assert_equal "Shipping", item.delivery_text
    assert_equal "Price text", item.price_text
    assert_equal "Usbkey", item.product_title
    assert_equal "image.jpg", item.product_image_url
    assert_equal 2, item.price_delivery
    assert_equal 9, item.price_product
  end
  
  test "it should start billing if target price is auto accepted" do
    start_order
    assess_order

    assert_equal :billing, @order.state
    assert_equal true, @order.questions.first["answer"]
  end

  test "it should send request to user if price it outside range" do
    start_order
    assess_order_with_higher_price

    assert_equal :querying, @order.state
    assert_equal false, @order.questions.first["answer"]
    assert ActionMailer::Base.deliveries.last.present?, "a notification email should have been sent"
  end
  
  test "it should reject order because of higher price" do
    start_order
    assess_order_with_higher_price
    reject_order
    
    assert_equal :failed, @order.state
    assert_equal "user", @order.error_code
    assert_equal "price_rejected", @order.message
    
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "a notification email should have been sent"
    assert_match /La commande a été annulée/, mail.decoded    
  end

  test "it should accept order if price is deemed good" do
    start_order
    assess_order_with_higher_price
    accept_order
    
    assert_equal :preparing, @order.state   
    assert_equal 16, @order.expected_price_total    
  end

  test "it should process order if billing has been accepted" do
    start_order
    assess_order
    billing_accepted
    
    assert_equal :injecting_payment, @order.state
  end

  test "it should fail order if billing has beed rejected" do
    start_order
    assess_order
    billing_rejected
    
    assert_equal :failed, @order.state
    assert_equal "user", @order.error_code
    assert_equal "billing_rejected", @order.message
  end
  
  test "it should process order with injection success" do
    start_order
    assess_order
    billing_accepted
    injection_success
    
    assert_equal :waiting_approval, @order.state
  end
  
  test "it should pause order with injection error" do
    start_order
    assess_order
    billing_accepted
    injection_error
    
    assert_equal :pending, @order.state
    assert_equal "limonetik", @order.error_code
    assert_equal "injection_error", @order.message
  end

  test "it should complete order with payment success" do
    start_order
    assess_order
    billing_accepted
    injection_success
    payment_success
    
    assert_equal :completed, @order.state
    assert ActionMailer::Base.deliveries.last.present?, "a notification email should have been sent"
  end

  test "it should pause order with payment error" do
    start_order
    assess_order
    billing_accepted
    injection_success
    payment_error
    
    assert_equal :pending, @order.state
    assert_equal "limonetik", @order.error_code
    assert_equal "payment_error", @order.message
  end    

  test "it should complete an order only if it was processing" do
    @order.state_name = "failed"
    @order.process "success", {
      "billing" => {
        "product" => 14,
        "shipping" => 2,
        "total" => 16,
        "shipping_info" => "info"
      }
    }
    assert_equal :failed, @order.reload.state
    assert !ActionMailer::Base.deliveries.last.present?, "a notification email shouldn't have been sent"
  end
  
  test "it should restart order with new account if account creation failed" do
   assert_difference('MerchantAccount.count', 1) do
     @order.process "failure", { "status" => "account_creation_failed" }
   end
   assert_equal :processing, @order.reload.state
  end
  
  test "it should restart order with new account if login failed" do
   old_id = @order.merchant_account.id
   assert_difference('MerchantAccount.count', 1) do
     @order.process "failure", { "status" => "login_failed" }
   end
   assert_equal 1, @order.reload.retry_count
   assert_not_equal old_id, @order.merchant_account.id
   assert_equal :processing, @order.state
  end
 
  test "it should process order validation failure" do
   @order.process "failure", { "status" => "order_validation_failed" }
   assert_equal :failed, @order.reload.state
   assert_equal "payment", @order.error_code
   assert ActionMailer::Base.deliveries.last.present?, "a notification email should have been sent"
  end
  
  test "it shouldn't restart order if maximum number of retries has been reached" do
   @order.retry_count = Rails.configuration.max_retry
   assert_difference('MerchantAccount.count', 0) do
     @order.process "failure", { "status" => "account_creation_failed" }
   end
   assert_equal :pending, @order.reload.state
   assert_equal "account", @order.error_code
  end
 
  test "it should set merchant account as created when message account_created received" do
    order = Order.create(
      :user_id => @user.id, 
      :products => [ {
        :url => "http://www.rueducommerce.fr/productA",
        :name => "Product A",
        :image_url => "http://www.rueducommerce.fr/logo.jpg" } ],        
      :address_id => @address.id,
      :payment_card_id => @card.id,
      :expected_price_total => 100,)
    assert_equal false, order.merchant_account.merchant_created
    order.process "message", { "message" => "account_created" }
    assert_equal true, order.merchant_account.reload.merchant_created    
  end
  
  test "it should clear message when state is not processing" do
    @order.process "message", { "message" => "bla" }
    @order.reload.process "success", {"billing" => {}}
    assert @order.reload.message.nil?
  end

  test "it should clear message and error when state going from pending to processing" do
    @order.state_name = "pending"
    @order.message = "bla"
    @order.error_code = "user"
    assert @order.start
    assert @order.reload.message.nil?
    assert @order.error_code.nil?
  end
  
  test "it should parametrize order with uuid" do
    assert_equal @order.uuid, @order.to_param
  end
  
  test "it should clear error_code when state becomes completed" do
    @order.process "failure", { "status" => "error" }
    assert @order.reload.error_code.present?
    assert_equal :pending, @order.state
    @order.state_name = "processing"
    @order.process "success", {"billing" => {}}    
    assert @order.reload.error_code.nil?
  end
  
  test "it should start an order only if start-allowed mode" do
    @order.state_name = "processing"
    assert !@order.start
    @order.state_name = "completed"
    assert !@order.start
    @order.state_name = "failed"
    assert !@order.start
    @order.state_name = "pending"
    assert @order.start
    @order.state_name = "initialized"
    assert @order.start
    @order.state_name = "querying"
    assert @order.start
  end
  
  test "it should time out an order and send notification email" do
    @order.error_code = "vulcain"
    @order.time_out
    assert_equal :failed, @order.reload.state
    
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "a notification email should have been sent"
    assert_match /Le back office Shopelia/, mail.decoded
  end
  
  test "it should match delayed & expired scopes" do
    @order.update_attribute :state_name, "pending"
    assert_equal 0, Order.delayed.count
    assert_equal 0, Order.expired.count

    @order.update_attribute :created_at, Time.now - 4.minutes
    assert_equal 1, Order.delayed.count
    assert_equal 0, Order.expired.count

    @order.update_attribute :created_at, Time.now - 5.hours
    assert_equal 1, Order.delayed.count
    assert_equal 1, Order.expired.count
  end
  
  test "it should match canceled scope" do
    @order.update_attribute :state_name, "querying"
    assert_equal 0, Order.canceled.count
    
    @order.update_attribute :created_at, Time.now - 3.hours
    assert_equal 1, Order.canceled.count    
  end
   
  test "it shouldn't cancel a completed order" do
    @order.update_attribute :state_name, "completed"
    @order.cancel
    assert_equal :completed, @order.reload.state
  end 

  test "it shouldn't confirm a failed order" do
    @order.update_attribute :state_name, "failed"
    @order.confirm
    assert_equal :failed, @order.reload.state    
  end 
   
private
  
  def start_order
    @order.start
    @order.reload
  end
  
  def callback_order verb, options
    @order.callback verb, options
    @order.reload
  end
  
  def pause_order
    start_order
    callback_order "failure", { "status" => "error" }
  end
  
  def time_out_order
    @order.time_out
    @order.reload
  end
  
  def cancel_order
    @order.cancel
    @order.reload
  end
  
  def assess_order
    @order.process "assess", { 
      "questions" => [
        { "id" => "3" }
      ],
      "products" => [
        { "url" => products(:usbkey).url,
          "delivery_text" => "Shipping", 
          "price_text" => "Price text", 
          "product_title" => "Usbkey", 
          "product_image_url" => "image.jpg", 
          "price_delivery" => 2, 
          "price_product" => 9 
        },
        { "url" => products(:headphones).url,
          "delivery_text" => "Shipping", 
          "price_text" => "Price text", 
          "product_title" => "Headphones", 
          "product_image_url" => "image.jpg", 
          "price_delivery" => 0, 
          "price_product" => 5 
        }
      ],
      "billing" => {
        "product" => 14,
        "shipping" => 2,
        "total" => 16
      }
    }
    @order.reload
  end
  
  def assess_order_with_higher_price
    @order.update_attirbute :expected_price_total, 10
    assess_order
  end
  
  def reject_order
    @order.reject
    @order.reload
  end
  
  def accept_order
    @order.accept
    @order.reload
  end
  
  def billing_accepted
    @order.billing_accepted
    @order.reload
  end
  
  def billing_rejected
    @order.billing_rejected
    @order.reload
  end
   
  def injection_success
    @order.injection_success
    @order.reload
  end 
  
  def injection_error
    @order.injection_error
    @order.reload
  end
  
  def payment_success
    @order.payment_success
    @order.reload
  end
  
  def payment_error
    @order.payment_error
    @order.reload
  end
   
end
