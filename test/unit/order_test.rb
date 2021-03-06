# -*- encoding : utf-8 -*-
require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  
  setup do
    @user = users(:elarch)
    @product = products(:usbkey)
    @order = orders(:elarch_rueducommerce)
    @card = payment_cards(:elarch_hsbc)
    @address = addresses(:elarch_neuilly) 
    @developer = developers(:prixing)
  end

  test "it should create order" do
    order = Order.create!(
      :user_id => @user.id,
      :developer_id => @developer.id,
      :payment_card_id => @card.id,
      :products => [ {
        :price => 90.356,
        :url => "http://www.cdiscount.com/Brother-Télécopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO",
        :name => "Papier normal Fax T102 Brother FAXT102G1",
        :image_url => "http://www.prixing.fr/images/product_images/2cf/2cfb0448418dc3f9f3fc517ab20c9631.jpg" } ],
      :address_id => @address.id,
      :expected_price_total => 100.356,
      :expected_price_product => 90.356,
      :expected_price_shipping => 10.001,
      :informations => "Options",
      :tracker => 'toto')
    assert order.persisted?, order.errors.full_messages.join(",")
    assert_equal :preparing, order.state
    assert order.merchant_account.present?
    assert order.uuid.present?
    assert_equal 1, order.reload.order_items.count
    assert_equal 90.36, order.expected_price_product
    assert_equal 10, order.expected_price_shipping
    assert_equal 100.36, order.expected_price_total
    assert_equal "toto", order.tracker
    assert_equal "Options", order.informations

    meta = order.meta_order
    assert meta.present?
    assert_equal @address.id, meta.address_id
    assert_equal @card.id, meta.payment_card_id
    assert_equal "mangopay", meta.billing_solution
    
    item = order.order_items.first
    assert_equal 1, item.quantity
    assert_equal 90.36, item.reload.price
    
    product = item.product
    assert_equal "http://www.cdiscount.com/Brother-Télécopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO", product.url
    assert_equal "Papier normal Fax T102 Brother FAXT102G1", product.name
    assert_equal "http://www.prixing.fr/images/product_images/2cf/2cfb0448418dc3f9f3fc517ab20c9631.jpg", product.image_url
    
    assert_equal "vulcain", order.injection_solution
    assert_equal "virtualis", order.cvd_solution
  end
  
  test "it should create multiple order items with quantities" do
    order = Order.create!(
      :user_id => @user.id,
      :developer_id => @developer.id,
      :payment_card_id => @card.id,
      :products => [
        { :url => "http://www.eveiletjeux.com/bac-a-sable-pop-up/produit/306367", :quantity => 2 },
        { :url => "http://www.eveiletjeux.com/bac-a-sable-fleur/produit/300173", :quantity => 1 },
        { :url => "http://www.eveiletjeux.com/jeu-de-societe-coloroflor/produit/306375", :quantity => 1 },
        { :url => "http://www.eveiletjeux.com/les-cookies-des-sables/produit/306562", :quantity => 1 },
        { :url => "http://www.eveiletjeux.com/les-cupcakes-des-sables/produit/306561", :quantity => 1 },
        { :url => "http://www.eveiletjeux.com/4-marqueurs-chunkie-couleurs-tropicales/produit/305851", :quantity => 1 },
        { :url => "http://www.eveiletjeux.com/montre-sablier-rose/produit/159487", :quantity => 1 }
      ],
      :address_id => @address.id,
      :expected_price_total => 100,
      :expected_price_product => 90,
      :expected_price_shipping => 10)

    assert order.persisted?, order.errors.full_messages.join(",")
    assert_equal 7, order.order_items.count
    assert_equal 8, order.order_items.map(&:quantity).sum
  end

  test "it should create order from product version id" do
    order = Order.create!(
      :user_id => @user.id,
      :developer_id => @developer.id,
      :payment_card_id => @card.id,
      :products => [
        { :product_version_id => product_versions(:usbkey).id, :quantity => 1 }
      ],
      :address_id => @address.id,
      :expected_price_total => 100,
      :expected_price_product => 90,
      :expected_price_shipping => 10)

    assert order.persisted?, order.errors.full_messages.join(",")
    item = order.order_items.first
    assert_equal 1, item.quantity
    assert_equal product_versions(:usbkey).id, item.product_version_id
    assert_equal 5, item.price
  end

  test "it should prepare item price from quantity" do
    order = Order.create!(
      :user_id => @user.id,
      :developer_id => @developer.id,
      :payment_card_id => @card.id,
      :products => [
        { :url => "http://www.eveiletjeux.com/bac-a-sable-pop-up/produit/306367", :quantity => 2 }
      ],
      :address_id => @address.id,
      :expected_price_total => 100,
      :expected_price_product => 90,
      :expected_price_shipping => 10)

    assert order.persisted?, order.errors.full_messages.join(",")
    item = order.reload.order_items.first
    assert_equal 2, item.quantity
    assert_equal 45, item.price
  end
  
  test "it should fill default value for prices if not set" do
    order = Order.create(
      :user_id => @user.id,
      :developer_id => @developer.id,
      :payment_card_id => @card.id,
      :products => [ {
        :url => "http://www.amazon.fr/Brother-Télécopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO",
        :name => "Papier normal Fax T102 Brother FAXT102G1",
        :image_url => "http://www.prixing.fr/images/product_images/2cf/2cfb0448418dc3f9f3fc517ab20c9631.jpg" } ],
      :address_id => @address.id,
      :expected_price_total => 100)
    assert order.persisted?, order.errors.full_messages.join(",")

    assert_equal 100, order.expected_price_product
    assert_equal 0, order.expected_price_shipping
    assert_equal 100, order.expected_price_total
    assert_equal 100, order.order_items.first.price
  end
 
  test "it should fill default value for prices if not set - variant" do
    order = Order.create(
      :user_id => @user.id,
      :developer_id => @developer.id,
      :payment_card_id => @card.id,
      :products => [ {
        :url => "http://www.amazon.fr/Brother-Télécopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO",
        :name => "Papier normal Fax T102 Brother FAXT102G1",
        :image_url => "http://www.prixing.fr/images/product_images/2cf/2cfb0448418dc3f9f3fc517ab20c9631.jpg" } ],
      :address_id => @address.id,
      :expected_price_product => 90,
      :expected_price_shipping => 10)
    assert order.persisted?, order.errors.full_messages.join(",")

    assert_equal 100, order.expected_price_total
    assert_equal 90, order.order_items.first.price
  end
  
  test "it should fail order creation with iconsistent prices" do
    order = Order.create(
      :user_id => @user.id,
      :developer_id => @developer.id,
      :payment_card_id => @card.id,
      :products => [ {
        :url => "http://www.amazon.fr/Brother-Télécopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO",
        :name => "Papier normal Fax T102 Brother FAXT102G1",
        :image_url => "http://www.prixing.fr/images/product_images/2cf/2cfb0448418dc3f9f3fc517ab20c9631.jpg" } ],
      :address_id => @address.id,
      :expected_price_product => 90,
      :expected_price_shipping => 10,
      :expected_price_total => 200)
      
    assert !order.persisted?, "The order shouldn't have save"
    assert_match /Les prix des produits ne correspondent pas au total de la commande/, order.errors.full_messages.first
  end

  test "it shouldn't be able to create same order in a 5 minutes delay" do
    CashfrontRule.destroy_all

    order = Order.create(
      :user_id => @user.id,
      :developer_id => @developer.id,
      :payment_card_id => @card.id,
      :products => [ {
        :url => "http://www.amazon.fr/one",
        :name => "Papier normal Fax T102 Brother FAXT102G1",
        :image_url => "http://www.prixing.fr/images/one.jpg" } ],
      :address_id => @address.id,
      :expected_price_total => 100)
    another = Order.create(
      :user_id => @user.id,
      :developer_id => @developer.id,
      :payment_card_id => @card.id,
      :products => [ {
        :url => "http://www.amazon.fr/another_product",
        :name => "Bla",
        :image_url => "http://www.prixing.fr/images/another.jpg" } ],
      :address_id => @address.id,
      :expected_price_total => 100)
    assert another.persisted?
    duplicate = Order.create(
      :user_id => @user.id,
      :developer_id => @developer.id,
      :payment_card_id => @card.id,
      :products => [ {
        :url => "http://www.amazon.fr/one",
        :name => "Papier normal Fax T102 Brother FAXT102G1",
        :image_url => "http://www.prixing.fr/images/one.jpg" } ],
      :address_id => @address.id,
      :expected_price_total => 100)

    assert !duplicate.persisted?
    assert_equal "Vous ne pouvez pas commander deux fois le même produit dans un délai de 5 minutes", duplicate.errors.full_messages.first
    
    order.update_attribute :created_at, 10.minutes.ago
    duplicate = Order.create(
      :user_id => @user.id,
      :developer_id => @developer.id,
      :payment_card_id => @card.id,
      :products => [ {
        :url => "http://www.amazon.fr/Brother-Télécopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO",
        :name => "Papier normal Fax T102 Brother FAXT102G1",
        :image_url => "http://www.prixing.fr/images/product_images/2cf/2cfb0448418dc3f9f3fc517ab20c9631.jpg" } ],
      :address_id => @address.id,
      :expected_price_total => 100)
      
    assert duplicate.persisted?
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
        :developer_id => @developer.id,
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
      :developer_id => @developer.id,
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

  test "it shouldn't accept urls from different merchants" do
    order = Order.create(
      :user_id => @user.id,
      :developer_id => @developer.id,
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
      :developer_id => @developer.id,
      :expected_price_total => 100,
      :address_id => @address.id,
      :payment_card_id => @card.id)
    assert !order.save, "Order shouldn't have saved"
    assert_equal I18n.t('orders.errors.no_product'), order.errors.full_messages.first
  end

  test "it shouldn't create order with invalid product" do
    order = Order.create(
      :user_id => @user.id, 
      :developer_id => @developer.id,
      :expected_price_total => 100,
      :address_id => @address.id,
      :products => [ { :invalid => "http://www.rueducommerce.fr/productA" } ],              
      :payment_card_id => @card.id)
    assert !order.persisted?, "Order shouldn't have saved"
    assert_equal I18n.t('orders.errors.invalid_product', :error => ''), order.errors.full_messages.first
  end
  
  test "it should clean urls" do
    CashfrontRule.destroy_all
    order = Order.new(
      :user_id => @user.id,
      :developer_id => @developer.id,
      :payment_card_id => @card.id,
      :products => [ {
        :url => "http://www.amazon.fr/Port-designs-Detroit-tablettes-pouces/dp/B00BIXXTCY?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B00BIXXTCY",
        :name => "Aladdin",
        :image_url => "http://www.amazon.fr/logo.jpg" } ],
      :address_id => @address.id,
      :expected_price_total => 100)
    assert order.save, order.errors.full_messages.join(",")
    assert_equal 1, order.reload.order_items.count
    assert_equal "http://www.amazon.fr/dp/B00BIXXTCY", order.order_items.first.product.url
  end
  
  test "it should set message" do
    start_order
    @order.callback "message", { "message" => "bla" }
    
    assert_equal "bla", @order.reload.message
  end
  
  test "it should start order" do
    start_order
    
    assert_equal :preparing, @order.state
  end
  
  test "it shouldn't start order if missing payment card" do
    @order.meta_order.update_attribute :payment_card_id, nil
    start_order
    
    assert_equal :initialized, @order.state
  end
  
  test "it shouldn't start order if without order items" do
    @order.order_items.destroy_all
    start_order
    
    assert_equal :initialized, @order.state
  end

  test "it should immediately fail order if merchant doesn't have vendor for Vulcain" do
    @order.merchant.update_attribute :vendor, nil
    start_order
    
    assert_equal :pending_agent, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "unsupported", @order.message
  end
   
  test "it should fail order if out of stock" do
    start_order
    callback_order "failure", { "status" => "out_of_stock" }
    
    assert_equal :failed, @order.state
    assert_equal "merchant", @order.error_code
    assert_equal "stock", @order.message
  end

  test "it should fail order if no delivery possible" do
    start_order
    callback_order "failure", { "status" => "no_delivery" }
    
    assert_equal :failed, @order.state
    assert_equal "merchant", @order.error_code
    assert_equal "delivery", @order.message
  end
  
  test "it should pause order with vulcain exception" do
    start_order
    callback_order "failure", { "status" => "exception" }
    
    assert_equal :pending_agent, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "exception", @order.message
  end

  test "it should pause order with vulcain error" do
    start_order
    callback_order "failure", { "status" => "error" }
    
    assert_equal :pending_agent, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "error", @order.message    
  end
  
  test "it should pause order with vulcain no_idle" do
    start_order
    callback_order "failure", { "status" => "no_idle" }
    
    assert_equal :pending_agent, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "no_idle", @order.message
  end

  test "it should pause order with vulcain driver problem" do
    start_order
    callback_order "failure", { "status" => "driver_failed" }
    
    assert_equal :pending_agent, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "driver_failed", @order.message
  end

  test "it should pause order with vulcain time out" do
    start_order
    callback_order "failure", { "status" => "order_timeout" }
    
    assert_equal :pending_agent, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "order_timeout", @order.message
  end

  test "it should pause order with vulcain dispatcher crash" do
    start_order
    callback_order "failure", { "status" => "dispatcher_crash" }
    
    assert_equal :pending_agent, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "dispatcher_crash", @order.message
  end

  test "it should pause order with vulcain order validation failure" do
    start_order
    callback_order "failure", { "status" => "order_validation_failed" }
    
    assert_equal :pending_agent, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "order_validation_failed", @order.message
  end

  test "it should pause order with vulcain uuid conflict" do
    start_order
    callback_order "failure", { "status" => "uuid_conflict" }
    
    assert_equal :pending_agent, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "uuid_conflict", @order.message
  end

  test "it should pause order with vulcain cart amount error" do
    start_order
    callback_order "failure", { "status" => "cart_amount_error" }
    
    assert_equal :pending_agent, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "cart_amount_error", @order.message
  end

  test "it should pause order with vulcain product not found" do
    start_order
    callback_order "failure", { "status" => "no_product_available" }
    
    assert_equal :failed, @order.state
    assert_equal "merchant", @order.error_code
    assert_equal "stock", @order.message
  end  

  test "it should pause order with gift message failure" do
    start_order
    callback_order "failure", { "status" => "gift_message_failure" }
    
    assert_equal :pending_agent, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "gift_message_failure", @order.message
  end  

  test "it should pause order with merchant address error" do
    start_order
    callback_order "failure", { "status" => "address_error" }
    
    assert_equal :pending_agent, @order.state
    assert_equal "merchant", @order.error_code
    assert_equal "address_error", @order.message
  end

  test "it should restart paused order" do
    pause_order
    start_order
    
    assert_equal :preparing, @order.state
  end
  
  test "it should time out paused order" do
    pause_order
    time_out_order
    
    assert_equal :failed, @order.state
    assert_equal "shopelia", @order.error_code
    assert_equal "timed_out", @order.message

    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "a notification email should have been sent"
    assert_match /Le back office Shopelia/, mail.decoded
  end
  
  test "it should cancel paused order" do
    pause_order
    cancel_order
    
    assert_equal :failed, @order.state
    assert_equal "shopelia", @order.error_code
    assert_equal "canceled", @order.message
  end
  
  test "it should update order when assessing" do
    start_order
    assess_order

    assert_equal 16, @order.prepared_price_total
    assert_equal 14, @order.prepared_price_product
    assert_equal 2, @order.prepared_price_shipping
    assert_equal 1, @order.questions.count
    assert_equal "3", @order.questions.first["id"]
    
    item = @order.order_items.where(:product_version_id => product_versions(:usbkey).id).first
    assert_equal 9, item.price
    
    assert_not_equal :pending_agent, @order.state
  end

  test "it should assess order with product version id" do
    start_order
    assess_order_with_product_version_id
    
    assert_equal 16, @order.prepared_price_total
    assert_equal 14, @order.prepared_price_product
    assert_equal 2, @order.prepared_price_shipping
    assert_equal 1, @order.questions.count
    assert_equal "3", @order.questions.first["id"]
    
    item = @order.order_items.where(:product_version_id => product_versions(:usbkey).id).first
    assert_equal 9, item.price
    
    assert_not_equal :pending_agent, @order.state
  end

  test "it should fail order if assess has invalid quantities" do
    start_order
    assess_order_with_invalid_quantity
    
    assert_equal :pending_agent, @order.state
    assert_equal "vulcain", @order.error_code
    assert_equal "invalid_quantity", @order.message
  end
  
  test "it should set missing product price if only one item" do
    order_items(:item2).destroy # keep only one item
    start_order
    assess_order_with_missing_price
    
    assert_equal 14, @order.order_items.first.price
    assert_not_equal :pending_agent, @order.state
  end
  
  test "it should fail assess if product prices doesn't match total" do
    start_order
    assess_order_invalid
    
    assert_equal :pending_agent, @order.state
    assert_equal false, @order.questions.first["answer"]
    assert_equal "shopelia", @order.error_code
    assert_match /Les prix des produits ne correspondent pas/, @order.message
  end

  test "it should assess amazon order with address in luxemburg" do
    @order.meta_order.address.update_attribute :country_id, countries(:luxemburg).id
    start_order
    assess_order_for_amazon_luxemburg

    assert_not_equal :pending_agent, @order.state

    assert_equal 15.38, @order.prepared_price_total
    assert_equal 15.38, @order.prepared_price_product
    assert_equal 0, @order.prepared_price_shipping
    
    item = @order.order_items.where(:product_version_id => product_versions(:usbkey).id).first
    assert_equal 8.65, item.price
    item = @order.order_items.where(:product_version_id => product_versions(:headphones).id).first
    assert_equal 6.73, item.price
  end

  test "it should send request to user if price it outside range" do
    start_order
    assess_order_with_higher_price

    assert_equal 16, @order.prepared_price_total
    assert_equal 14, @order.prepared_price_product
    assert_equal 2, @order.prepared_price_shipping

    assert_equal :querying, @order.state
    assert_equal false, @order.questions.first["answer"]
    assert ActionMailer::Base.deliveries.last.present?, "a notification email should have been sent"
    
    mail = ActionMailer::Base.deliveries.last
    assert_match /\/zen\/orders\/#{@order.uuid}\/confirm/, mail.decoded
    assert_match /\/zen\/orders\/#{@order.uuid}\/cancel/, mail.decoded
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
    assert_match /Vous avez annulé la commande/, mail.decoded    
  end

  test "it should accept order if price is deemed good" do
    start_order
    assess_order_with_higher_price
    accept_order
    
    assert_equal :preparing, @order.state   
    assert_equal 16, @order.expected_price_total    
  end

  test "it should complete an order only if it was processing" do
    pause_order
    order_success
    
    assert_equal :pending_agent, @order.state
    assert_equal 1, ActionMailer::Base.deliveries.count, "a notification email shouldn't have been sent"
    assert_match /Echec/, ActionMailer::Base.deliveries.last.decoded
  end
  
  test "it should restart order with new account if account creation failed" do
    start_order
    assert_difference('MerchantAccount.count', 1) do
      @order.callback "failure", { "status" => "account_creation_failed" }
    end
    assert_equal :preparing, @order.reload.state
  end

  test "it should restart order with new account if login failed" do
    start_order
    old_id = @order.merchant_account.id
    assert_difference('MerchantAccount.count', 1) do
      @order.callback "failure", { "status" => "login_failed" }
    end
    assert_equal 1, @order.reload.retry_count
    assert_not_equal old_id, @order.merchant_account.id
    assert_equal :preparing, @order.state
  end

  test "it should process order validation failure" do
    start_order
    @order.callback "failure", { "status" => "order_validation_failed" }
    assert_equal :pending_agent, @order.reload.state
    assert_equal "vulcain", @order.error_code
    assert_equal "order_validation_failed", @order.message
    #assert ActionMailer::Base.deliveries.last.present?, "a notification email should have been sent"
  end

  test "it shouldn't restart order if maximum number of retries has been reached" do
    start_order
    @order.retry_count = Rails.configuration.max_retry
    assert_difference('MerchantAccount.count', 0) do
      @order.callback "failure", { "status" => "account_creation_failed" }
    end
    assert_equal :pending_agent, @order.reload.state
    assert_equal "merchant", @order.error_code
    assert_equal "account_creation_failed", @order.message
  end
 
  test "it should set merchant account as created when message account_created received" do
    order = Order.create(
      :user_id => @user.id, 
      :developer_id => @developer.id,
      :products => [ {
        :url => "http://www.rueducommerce.fr/productA",
        :name => "Product A",
        :image_url => "http://www.rueducommerce.fr/logo.jpg" } ],        
      :address_id => @address.id,
      :payment_card_id => @card.id,
      :expected_price_total => 100,)
    assert_equal false, order.merchant_account.merchant_created
    order.callback "message", { "message" => "account_created" }
    assert_equal true, order.merchant_account.reload.merchant_created    
  end

  test "it should parametrize order with uuid" do
    assert_equal @order.uuid, @order.to_param
  end
  
  test "it should start an order only if start-allowed mode" do
    @order.state_name = "preparing"
    assert !@order.start
    @order.state_name = "completed"
    assert !@order.start
    @order.state_name = "failed"
    assert !@order.start
    @order.state_name = "pending_agent"
    assert @order.start
    @order.state_name = "initialized"
    assert @order.start
    @order.state_name = "querying"
    assert @order.start
  end
  
  test "it should match delayed & expired scopes" do
    @order.update_attribute :created_at, Time.now
    @order.update_attribute :state_name, "pending_agent"
    assert_equal 0, Order.delayed.count
    assert_equal 0, Order.expired.count

    @order.update_attribute :created_at, Time.now - 4.minutes
    assert_equal 1, Order.delayed.count
    assert_equal 0, Order.expired.count

    @order.update_attribute :created_at, Time.now - 21.hours
    assert_equal 1, Order.delayed.count
    assert_equal 1, Order.expired.count
  end
  
  test "it should match canceled scope" do
    @order.update_attribute :state_name, "querying"
    assert_equal 0, Order.canceled.count
    
    @order.update_attribute :updated_at, Time.now - 13.hours
    assert_equal 1, Order.canceled.count    
  end
  
  test "it should match preparing stale scope" do
    start_order
    assert_equal 0, Order.preparing_stale.count
    
    @order.update_attribute :updated_at, Time.now - 6.minutes
    assert_equal 1, Order.preparing_stale.count    
  end  
   
  test "it shouldn't cancel a completed order" do
    @order.update_attribute :state_name, "completed"
    @order.cancel
    assert_equal :completed, @order.reload.state
  end 

  test "it shouldn't accept a failed order" do
    @order.update_attribute :state_name, "failed"
    @order.accept
    assert_equal :failed, @order.reload.state    
  end 
  
  test "order should be audited" do
    start_order
    
    assert !@order.audits.empty?
  end
  
  test "it should time out if vulcain is stale" do
    start_order
    @order.vulcain_time_out
    
    assert_equal :pending_agent, @order.reload.state
    assert_equal "vulcain", @order.error_code
    assert_equal "preparing_stale", @order.message
  end
 
  test "it should compute cashback value" do
    assert_equal 0.30, orders(:elarch_amazon_billing).cashfront_value

    CashfrontRule.create!(
      merchant_id:merchants(:amazon).id,
      rebate_percentage:6,
      developer_id:developers(:prixing).id,
      device_id:devices(:samsung).id,
      max_rebate_value:10)
    assert_equal 0.60, orders(:elarch_amazon_billing).cashfront_value
  end
  
  test "[alpha] it should continue order if target price is same than expected" do
    configuration_alpha
    start_order
    assess_order
    
    assert_equal :preparing, @order.state
    assert_equal true, @order.questions.first["answer"]
    assert_equal "vulcain_assessment_done", @order.message
  end

  test "[alpha] it should continue order if target price is less than expected" do
    configuration_alpha
    start_order
    assess_order_with_lower_price
    
    assert_equal :preparing, @order.state
    assert_equal true, @order.questions.first["answer"]
    assert_equal "vulcain_assessment_done", @order.message
    
    assert_equal 16, @order.prepared_price_total
    assert_equal 2, @order.prepared_price_shipping
    assert_equal 14, @order.prepared_price_product
  end
  
  test "[alpha] it should complete order" do
    configuration_alpha
    start_order
    assess_order
    order_success

    assert_equal :completed, @order.state, @order.inspect
    assert_equal 14, @order.billed_price_product
    assert_equal 2, @order.billed_price_shipping
    assert_equal 16, @order.billed_price_total
  end

  test "[alpha] it should auto cancel order if price is higher" do
    configuration_alpha
    start_order
    assess_order_with_higher_price
    
    assert_equal :querying, @order.state
  end

  test "[beta] it should complete order" do
    configuration_beta
    start_order
    assess_order

    assert_equal :pending_injection, @order.state
    assert_equal true, @order.questions.first["answer"]
    
    injection_success
    assert_equal :pending_clearing, @order.state
    
    clearing_success
    assert_equal :completed, @order.state
    
    #assert_equal 14, @order.billed_price_product
    #assert_equal 2, @order.billed_price_shipping
    #assert_equal 16, @order.billed_price_total    
  end

  test "[beta] it should fail order if billing failed" do
    configuration_beta
    @order.expected_price_total = 333.05
    @order.expected_price_shipping = 33.05
    @order.expected_price_product = 300
    start_order
    assess_order_billing_failure

    assert_equal :failed, @order.state
    assert_equal "billing", @order.error_code
    assert_match /Do not honor/, @order.message
    assert_equal false, @order.questions.first["answer"]
  end
  
  test "[virtualis] it should complete order" do
    skip

    configuration_virtualis
    start_order
    assess_order

    assert @order.meta_order.mangopay_wallet_id.present?
    assert_equal 1, @order.meta_order.billing_transactions.count

    billing_transaction = @order.meta_order.billing_transactions.first
    assert billing_transaction.mangopay_contribution_id.present?
    assert billing_transaction.success?
    assert_equal 1600, billing_transaction.amount
    assert_equal 1600, billing_transaction.mangopay_contribution_amount

    payment_transaction = @order.payment_transaction
    assert payment_transaction.present?
    assert_equal "virtualis", payment_transaction.processor
    assert payment_transaction.virtual_card.present?
    
    order_success
    
    assert_equal :completed, @order.state
    assert_equal 14, @order.billed_price_product
    assert_equal 2, @order.billed_price_shipping
    assert_equal 16, @order.billed_price_total  
  end

  test "[amazon] it should complete order" do
    CashfrontRule.destroy_all
    configuration_amazon
    start_order
    assess_order

    assert @order.meta_order.mangopay_wallet_id.present?
    assert_equal 1, @order.meta_order.billing_transactions.count

    billing_transaction = @order.meta_order.billing_transactions.first
    assert billing_transaction.mangopay_contribution_id.present?
    assert billing_transaction.success?
    assert_equal 1600, billing_transaction.amount
    assert_equal 1600, billing_transaction.mangopay_contribution_amount

    payment_transaction = @order.payment_transaction
    assert payment_transaction.present?
    assert_equal "amazon", payment_transaction.processor
    assert payment_transaction.mangopay_amazon_voucher_id.present?
    assert payment_transaction.mangopay_amazon_voucher_code.present?    
    
    order_success
    
    assert_equal :completed, @order.state
    assert_equal 14, @order.billed_price_product
    assert_equal 2, @order.billed_price_shipping
    assert_equal 16, @order.billed_price_total    
  end

  test "[amazon] it should complete order with lower price than expected" do
    CashfrontRule.destroy_all
    configuration_amazon
    start_order
    assess_order_with_lower_price

    billing_transaction = @order.meta_order.billing_transactions.first
    assert_equal 1600, billing_transaction.amount

    order_success

    assert_equal :completed, @order.state
    assert_equal 14, @order.billed_price_product
    assert_equal 2, @order.billed_price_shipping
    assert_equal 16, @order.billed_price_total    
  end

  test "[amazon] it should complete order with cashfront" do
    configuration_amazon_cashfront
    prepare_master_cashfront_account

    start_order
    assess_order_cashfront

    assert_equal 16, @order.prepared_price_total
    assert_equal 2, @order.prepared_price_shipping
    assert_equal 14, @order.prepared_price_product
    assert_equal 0.42, @order.cashfront_value

    assert @order.meta_order.mangopay_wallet_id.present?
    assert_equal 2, @order.meta_order.billing_transactions.count

    billing_transaction_mp = @order.meta_order.billing_transactions.mangopay.first
    assert billing_transaction_mp.mangopay_contribution_id.present?
    assert billing_transaction_mp.success?
    assert_equal 1558, billing_transaction_mp.amount
    assert_equal 1558, billing_transaction_mp.mangopay_contribution_amount
    assert_equal @order.meta_order.mangopay_wallet_id, billing_transaction_mp.mangopay_destination_wallet_id

    billing_transaction_cf = @order.meta_order.billing_transactions.cashfront.first
    assert_equal 42, billing_transaction_cf.amount
    assert billing_transaction_cf.mangopay_transfer_id.present?
    assert billing_transaction_cf.success

    payment_transaction = @order.payment_transaction
    assert payment_transaction.present?
    assert_equal "amazon", payment_transaction.processor
    assert_equal 1600, payment_transaction.amount
    assert payment_transaction.mangopay_amazon_voucher_id.present?
    assert payment_transaction.mangopay_amazon_voucher_code.present?    
    
    order_success
    
    assert_equal :completed, @order.state
    assert_equal 14, @order.billed_price_product
    assert_equal 2, @order.billed_price_shipping
    assert_equal 16, @order.billed_price_total
  end

  test "[amazon] it should update cashfront with lower price" do
    configuration_amazon_cashfront
    prepare_master_cashfront_account

    start_order
    assess_order_with_lower_price_cashfront

    assert_equal 0.42, @order.expected_cashfront_value
  end

  test "[amazon] it shouldn't complete order if expected cashfront value is not meet" do
    configuration_amazon_cashfront
    prepare_master_cashfront_account
    
    @order.expected_cashfront_value = 1.0
    assert !@order.save
  end

  test "[amazon] it should complete order with cashfront in two times, in case master balance is negative" do
    configuration_amazon_cashfront
    prepare_master_cashfront_account(0)

    start_order
    assess_order_cashfront

    assert @order.meta_order.mangopay_wallet_id.present?
    assert_equal 2, @order.meta_order.billing_transactions.count

    billing_transaction_mp = @order.meta_order.billing_transactions.mangopay.first
    assert billing_transaction_mp.mangopay_contribution_id.present?
    assert billing_transaction_mp.success?
    assert_equal 1558, billing_transaction_mp.amount
    assert_equal 1558, billing_transaction_mp.mangopay_contribution_amount
    assert_equal @order.meta_order.mangopay_wallet_id, billing_transaction_mp.mangopay_destination_wallet_id

    billing_transaction_cf = @order.meta_order.billing_transactions.cashfront.first
    assert_equal 42, billing_transaction_cf.amount
    assert !billing_transaction_cf.success
    assert billing_transaction_cf.mangopay_transfer_id.nil?

    assert_equal :pending_agent, @order.state
    assert_equal "shopelia", @order.error_code
    assert_match /cashfront/, @order.message
  
    assert @order.payment_transaction.nil?

    prepare_master_cashfront_account(10000)
    start_order
    assess_order_cashfront

    payment_transaction = @order.payment_transaction
    assert payment_transaction.present?
    assert_equal "amazon", payment_transaction.processor
    assert_equal 1600, payment_transaction.amount
    assert payment_transaction.mangopay_amazon_voucher_id.present?
    assert payment_transaction.mangopay_amazon_voucher_code.present?    
    
    order_success
    
    assert_equal :completed, @order.state
    assert_equal 14, @order.billed_price_product
    assert_equal 2, @order.billed_price_shipping
    assert_equal 16, @order.billed_price_total
  end

  test "[amazon] it should complete order with cashfront in two times, in case vulcain fails" do
    skip 
    
    configuration_amazon_cashfront
    prepare_master_cashfront_account

    start_order
    assess_order_cashfront

    @order.update_attribute :state_name, "pending_agent"    

    start_order
    assess_order_cashfront

    order_success

    assert_equal :completed, @order.state
    assert_equal 14, @order.billed_price_product
    assert_equal 2, @order.billed_price_shipping
    assert_equal 16, @order.billed_price_total
  end

=begin
  test "[beta] it should process order if billing has been accepted" do
    configuration_beta
    start_order
    assess_order
    billing_accepted
    
    assert_equal :injection, @order.state
  end

  test "[beta] it should fail order if billing has beed rejected" do
    configuration_beta
    start_order
    assess_order
    billing_rejected
    
    assert_equal :failed, @order.state
    assert_equal "user", @order.error_code
    assert_equal "billing_rejected", @order.message
  end
  
  test "[beta] it should process order with injection success" do
    configuration_beta
    start_order
    assess_order
    billing_accepted
    injection_success
    
    assert_equal :pending_clearing, @order.state
  end
  
  test "[beta] it should pause order with injection error" do
    configuration_beta
    start_order
    assess_order
    billing_accepted
    injection_error
    
    assert_equal :pending_agent, @order.state
    assert_equal "limonetik", @order.error_code
    assert_equal "injection_error", @order.message
  end

  test "[beta] it should complete order with clearing success" do
    configuration_beta
    start_order
    assess_order
    billing_accepted
    injection_success
    clearing_success
    
    assert_equal :completed, @order.state
    assert ActionMailer::Base.deliveries.last.present?, "a notification email should have been sent"
  end

  test "[beta] it should pause order with payment error" do
    configuration_beta
    start_order
    assess_order
    billing_accepted
    injection_success
    clearing_error
    
    assert_equal :pending_agent, @order.state
    assert_equal "limonetik", @order.error_code
    assert_equal "payment_error", @order.message
  end    
=end
   
  private
  
  def configuration_alpha
    @order.meta_order.update_attribute :billing_solution, nil
    @order.injection_solution = "vulcain"
    @order.cvd_solution = "user"
    @order.save
  end
  
  def configuration_beta
    @order.meta_order.update_attribute :billing_solution, "mangopay"
    @order.injection_solution = "limonetik"
    @order.cvd_solution = "limonetik"  
    @order.save
  end

  def configuration_amazon
    @order.order_items.each { |item| item.product_version.product.update_attribute :merchant_id, merchants(:amazon).id }
    @order.meta_order.update_attribute :billing_solution, "mangopay"
    @order.injection_solution = "vulcain"
    @order.cvd_solution = "amazon"
    @order.save
  end

  def configuration_virtualis
    @order.meta_order.update_attribute :billing_solution, "mangopay"
    @order.injection_solution = "vulcain"
    @order.cvd_solution = "virtualis"
    @order.save
  end

  def configuration_amazon_cashfront
    @order.expected_cashfront_value = 0.42
    configuration_amazon
  end
  
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
    @order.shopelia_time_out
    @order.reload
  end
  
  def cancel_order
    @order.cancel
    @order.reload
  end
  
  def assess_order
    @order.callback "assess", { 
      "questions" => [
        { "id" => "3" }
      ],
      "products" => [
        { "url" => products(:usbkey).url,
          "price" => 9
        },
        { "url" => products(:headphones).url,
          "price_product" => 5
        }
      ],
      "billing" => {
        "shipping" => 2,
        "total" => 16
      }
    }
    @order.reload
  end

  def assess_order_with_product_version_id
    @order.callback "assess", { 
      "questions" => [
        { "id" => "3" }
      ],
      "products" => [
        { "product_version_id" => product_versions(:usbkey).id,
          "price" => 9
        },
        { "product_version_id" => product_versions(:headphones).id,
          "price" => 5
        }
      ],
      "billing" => {
        "shipping" => 2,
        "total" => 16
      }
    }
    @order.reload
  end  

  def assess_order_with_invalid_quantity
    @order.callback "assess", { 
      "questions" => [
        { "id" => "3" }
      ],
      "products" => [
        { "product_version_id" => product_versions(:usbkey).id,
          "price" => 9,
          "quantity" => 2
        },
        { "product_version_id" => product_versions(:headphones).id,
          "price" => 5
        }
      ],
      "billing" => {
        "shipping" => 2,
        "total" => 16
      }
    }
    @order.reload
  end  

  def assess_order_with_missing_price
    @order.callback "assess", { 
      "questions" => [
        { "id" => "3" }
      ],
      "products" => [
        { "url" => products(:usbkey).url
        }
      ],
      "billing" => {
        "shipping" => 2,
        "total" => 16
      }
    }
    @order.reload
  end
  
  def assess_order_invalid
    @order.callback "assess", { 
      "questions" => [
        { "id" => "3" }
      ],
      "products" => [
         { "url" => products(:usbkey).url,
           "price" => 5,
           "id" => product_versions(:usbkey).id 
         },
         { "url" => products(:headphones).url,
           "price_product" => 5,
           "id" => product_versions(:headphones).id 
         }
      ],
      "billing" => {
        "shipping" => 2,
        "total" => 16
      }
    }
    @order.reload
  end
  
  def assess_order_billing_failure
     @order.callback "assess", { 
       "questions" => [
         { "id" => "3" }
       ],
       "products" => [
         { "url" => products(:usbkey).url,
           "price" => 200,
           "id" => product_versions(:usbkey).id 
         },
         { "url" => products(:headphones).url,
           "price_product" => 100,
           "id" => product_versions(:headphones).id 
         }
       ],
       "billing" => {
         "shipping" => 33.05,
         "total" => 333.05
       }
     }
     @order.reload
  end  

  def assess_order_for_amazon_luxemburg
    @order.callback "assess", { 
      "questions" => [
        { "id" => "3" }
      ],
      "products" => [
        { "url" => products(:usbkey).url,
          "price" => 9
        },
        { "url" => products(:headphones).url,
          "price_product" => 7
        }
      ],
      "billing" => {
        "shipping" => 0,
        "total" => 15.38
      }
    }
    @order.reload
  end
  
  def assess_order_with_higher_price
    @order.expected_price_total = 10
    @order.expected_price_shipping = 2
    @order.expected_price_product = 8
    @order.save
    assess_order
  end

  def assess_order_with_lower_price
    @order.expected_price_total = 20
    @order.expected_price_shipping = 6
    @order.expected_price_product = 14
    @order.save
    assess_order
  end

  def assess_order_cashfront
    @order.expected_cashfront_value = 0.42
    @order.save
    assess_order
  end

  def assess_order_with_lower_price_cashfront
    @order.expected_cashfront_value = 0.60
    @order.save
    assess_order_with_lower_price
  end

  def reject_order
    @order.reject "price_rejected"
    @order.reload
  end
  
  def accept_order
    @order.accept
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
  
  def clearing_success
    @order.update_attribute :billed_price_total, 16
    @order.clearing_success
    @order.reload
  end
  
  def clearing_error
    @order.clearing_error
    @order.reload
  end
  
  def order_success
    @order.callback "success", {
      "billing" => {
        "shipping" => 2,
        "total" => 16,
        "shipping_info" => "info"
      }
    }
    @order.reload
  end 
  
end
