# -*- encoding : utf-8 -*-
require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  fixtures :users, :products, :merchants, :orders, :payment_cards, :order_items, :addresses, :merchant_accounts
  
  setup do
    @user = users(:elarch)
    @product = products(:usbkey)
    @merchant = merchants(:rueducommerce)
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
    order = Order.new(
      :user_id => @user.id,
      :merchant_id => @merchant.id,
      :payment_card_id => @card.id,
      :products => [ {
        :url => "http://www.rueducommerce.fr/productA",
        :name => "Product A",
        :image_url => "http://www.rueducommerce.fr/logo.jpg" } ],
      :address_id => @address.id,
      :expected_price_total => 100)
    assert order.save, order.errors.full_messages.join(",")
    assert_equal :processing, order.state
    assert order.merchant_account.present?
    assert order.uuid.present?
    assert_equal 1, order.reload.order_items.count
    assert_equal @merchant.id, order.merchant_id    
    
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "a notification email should have been sent"
    assert_match /Rue du Commerce/, mail.encoded
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
      :merchant_id => @merchant.id, 
      :products => [ {
        :url => "http://www.rueducommerce.fr/productA",
        :name => "Product A",
        :image_url => "http://www.rueducommerce.fr/logo.jpg" } ],        
      :payment_card_id => @card.id)
    assert !order.save, "Order shouldn't have saved"
    assert_equal "L'adresse doit être renseignée", order.errors.full_messages.first
  end

  test "it shouldn't create order without payment_card specified" do
    order = Order.new(
      :user_id => @user.id, 
      :expected_price_total => 100,
      :products => [ {
        :url => "http://www.rueducommerce.fr/productA",
        :name => "Product A",
        :image_url => "http://www.rueducommerce.fr/logo.jpg" } ],        
      :merchant_id => @merchant.id, 
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
    assert order.save, order.errors.full_messages.join(",")
    assert_equal 1, order.order_items.count
  end
  
  test "it should start order" do
    @order.start
    assert_equal :processing, @order.reload.state
  end
  
  test "it should fail order with exception" do
    @order.process "failure", { "message" => "exception" }
    assert_equal :pending, @order.reload.state
    assert_equal "vulcain_exception", @order.error_code
  end

  test "it should fail order with error" do
    @order.process "failure", { "message" => "error" }
    assert_equal :pending, @order.reload.state
    assert_equal "vulcain_error", @order.error_code
  end
  
  test "it should fail order with lack of vulcains" do
    @order.process "failure", { "message" => "no_idle" }
    assert_equal :pending, @order.reload.state
    assert_equal "vulcain_error", @order.error_code
  end

  test "it should fail order with driver problem" do
    @order.process "failure", { "message" => "driver_failed" }
    assert_equal :pending, @order.reload.state
    assert_equal "vulcain_error", @order.error_code
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
    assert_equal :aborted, @order.reload.state
    assert_equal false, @order.questions.first["answer"]
    assert_equal "price_range", @order.error_code
  end

  test "it should succeed order" do
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
  end
  
  test "it should restart order with new account if account creation failed" do
   assert_difference('MerchantAccount.count', 1) do
     @order.process "failure", { "message" => "account_creation_failed" }
   end
   assert_equal :processing, @order.reload.state
  end
  
  test "it should restart order with new account if login failed" do
   old_id = @order.merchant_account.id
   assert_difference('MerchantAccount.count', 1) do
     @order.process "failure", { "message" => "login_failed" }
   end
   assert_equal 1, @order.reload.retry_count
   assert_not_equal old_id, @order.merchant_account.id
   assert_equal :processing, @order.state
  end
 
  test "it should process order validation failure" do
   @order.process "failure", { "message" => "order_validation_failed" }
   assert_equal :aborted, @order.reload.state
   assert_equal "payment_refused", @order.error_code
  end
  
  test "it shouldn't restart order if maximum number of retries has been reached" do
   @order.retry_count = Rails.configuration.max_retry
   assert_difference('MerchantAccount.count', 0) do
     @order.process "failure", { "message" => "account_creation_failed" }
   end
   assert_equal :pending, @order.reload.state
   assert_equal "account_error", @order.error_code
  end
 
  test "it should set merchant account as created when message account_created received" do
    order = Order.create(
      :user_id => @user.id, 
      :merchant_id => @merchant.id, 
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
 
end
