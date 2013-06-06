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
    @content = { 
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
    
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "a notification email should have been sent"
    assert_match /Amazon/, mail.encoded
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
    assert_equal I18n.t('orders.errors.invalid_product'), order.errors.full_messages.first
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
  
  test "it should start order" do
    @order.start
    assert_equal :processing, @order.reload.state
  end
  
  test "it should fail order with exception" do
    @order.process "failure", { "status" => "exception" }
    assert_equal :pending, @order.reload.state
    assert_equal "vulcain", @order.error_code
    assert_equal "exception", @order.message
  end

  test "it should fail order with error" do
    @order.process "failure", { "status" => "error" }
    assert_equal :pending, @order.reload.state
    assert_equal "vulcain", @order.error_code
    assert_equal "error", @order.message    
  end
  
  test "it should fail order with lack of vulcains" do
    @order.process "failure", { "status" => "no_idle" }
    assert_equal :pending, @order.reload.state
    assert_equal "vulcain", @order.error_code
    assert_equal "no_idle", @order.message
  end

  test "it should fail order with driver problem" do
    @order.process "failure", { "status" => "driver_failed" }
    assert_equal :pending, @order.reload.state
    assert_equal "vulcain", @order.error_code
    assert_equal "driver_failed", @order.message
  end

  test "it should time out order" do
    @order.process "failure", { "status" => "order_timeout" }
    assert_equal :pending, @order.reload.state
    assert_equal "vulcain", @order.error_code
    assert_equal "order_timeout", @order.message
  end

  test "it should fail order with dispatcher crash" do
    @order.process "failure", { "status" => "dispatcher_crash" }
    assert_equal :pending, @order.reload.state
    assert_equal "vulcain", @order.error_code
    assert_equal "dispatcher_crash", @order.message
  end

  test "it should fail order if uuid conflict" do
    @order.process "failure", { "status" => "uuid_conflict" }
    assert_equal :pending, @order.reload.state
    assert_equal "vulcain", @order.error_code
    assert_equal "uuid_conflict", @order.message
  end

  test "it should set message" do
    @order.process "message", { "message" => "bla" }
    assert_equal "bla", @order.message
  end

  test "it should process confirmation request" do
    @order.process "assess", @content
    assert_equal :processing, @order.reload.state
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

  test "it should auto confirm order if target price is within range" do
    @order.process "assess", @content
    assert_equal :processing, @order.reload.state
    assert_equal true, @order.questions.first["answer"]
  end

  test "it should cancel order if target price it outside range" do
    @order.expected_price_total = 10
    @order.process "assess", @content
    assert_equal :failed, @order.reload.state
    assert_equal false, @order.questions.first["answer"]
    assert_equal "price", @order.error_code
    assert ActionMailer::Base.deliveries.last.present?, "a notification email should have been sent"
  end

  test "it should complete order" do
    @order.process "success", {
      "billing" => {
        "product" => 14,
        "shipping" => 2,
        "total" => 16,
        "shipping_info" => "info"
      }
    }
    assert_equal :completed, @order.reload.state
    assert_equal "info", @order.shipping_info
    assert_equal 16, @order.billed_price_total
    assert_equal 14, @order.billed_price_product
    assert_equal 2, @order.billed_price_shipping
    assert ActionMailer::Base.deliveries.last.present?, "a notification email should have been sent"
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
  
  test "it should parametrize order with uuid" do
    assert_equal @order.uuid, @order.to_param
  end
  
  test "it should clear error_code when state becomes completed" do
    @order.process "failure", { "status" => "error" }
    assert @order.reload.error_code.present?
    @order.reload.process "success", {"billing" => {}}    
    assert @order.reload.error_code.nil?
  end
  
  test "it should start an order only if initialized or pending mode" do
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
  end
  
  test "it should time out an order and send notification email" do
    @order.error_code = "vulcain"
    @order.time_out
    assert_equal :failed, @order.reload.state
    
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "a notification email should have been sent"
    assert_match /Le back office Shopelia est en maintenance/, mail.decoded
  end
   
end
