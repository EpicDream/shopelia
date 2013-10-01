# -*- encoding : utf-8 -*-
require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  
  test "it should create product" do
    product = Product.new(
      :name => 'Product',
      :merchant_id => merchants(:rueducommerce).id,
      :url => 'http://www.rueducommerce.fr/product',
      :image_url => 'http://www.rueducommerce.fr/image',
      :options_completed => true)
    assert product.save, product.errors.full_messages.join(",")
    assert_equal 1, product.product_versions.count
    assert product.options_completed?
    
    product.name = "New name"
    assert product.save, product.errors.full_messages.join(",")
  end
  
  test "it should create product from url" do
    product = Product.new(:url => 'http://www.rueducommerce.fr/product')
    assert product.save, product.errors.full_messages.join(",")
    assert_equal merchants(:rueducommerce).id, product.merchant_id
  end
  
  test "it should create new merchant if not found" do
    assert_difference("Merchant.count", 1) do
      product = Product.new(:url => 'http://www.bla.fr/product')
      assert product.save, product.errors.full_messages.join(",")
    end
  end

  test "it should unaccent url" do
    product = Product.new(:url => "http://www.rueducommerce.fr/product-é")
    assert product.save, product.errors.full_messages.join(",")
    assert_equal "http://www.rueducommerce.fr/product-e", product.url
  end

  test "it should clean url" do
    product = Product.new(:url => "http://www.amazon.fr/Brother-Telecopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO")
    assert product.save, product.errors.full_messages.join(",")
    assert_equal "http://www.amazon.fr/dp/B0006ZUFUO", product.url
  end

  test "it should fetch existing product" do
    assert_equal products(:headphones), Product.fetch("http://www.rueducommerce.fr/productB")
  end
  
  test "it should fail fetch if url is null" do
    assert_difference(["Product.count","ProductMaster.count","ProductVersion.count"], 0) do
      assert Product.fetch(nil).nil?
    end
  end
  
  test "it should create and fetch new product" do
    assert_difference('Product.count', 1) do
      Product.fetch("http://www.rueducommerce.fr/productC")
    end
    assert_difference('Product.count', 1) do
      Product.fetch("http://www.fnac.com/Tous-les-Enregistreurs/Enregistreur-DVD-Enregistreur-Blu-ray/nsh180760/w-4")
    end
  end
  
  test "it should truncate name to 250 chars" do
    product = Product.new(
      :url => 'http://www.amazon.fr/product',
      :name => "0" * 500
    )
    assert product.save
    
    assert_equal 250, product.name.length
  end
  
  test "it should assess versions quality" do
    product = products(:usbkey)
    product.assess_versions
    assert !product.viking_failure

    ProductVersion.create!(
      product_id:product.id,
      available:true)
    assert !product.viking_failure

    product.product_versions.update_all "price=null"
    product.reload.assess_versions
    assert product.viking_failure
  end
  
  test "it should get all products needing a Viking check" do
    [products(:headphones).url,products(:usbkey).url].each do |url|
      Event.create(
        :url => url,
        :developer_id => developers(:prixing).id,
        :device_id => devices(:web).id,
        :action => Event::VIEW)
    end
    Event.create(
      :url => "http://www.toto.fr/productA",
      :developer_id => developers(:prixing).id,
      :device_id => devices(:web).id,
      :action => Event::REQUEST)
    assert_equal 2, Product.viking_pending.count
    products(:headphones).update_attribute :versions_expires_at, 1.hour.from_now
    assert_equal 1, Product.viking_pending.count
  end

  test "it shouldn't need a viking check if product has been sent to viking" do
    Event.create(
      :url => products(:headphones).url,
      :developer_id => developers(:prixing).id,
      :device_id => devices(:web).id,
      :action => Event::VIEW)
    products(:headphones).update_attribute :viking_sent_at, Time.now

    assert_equal 0, Product.viking_pending.count
  end

  test "it should get all products needing a Viking check in batch mode" do
    [products(:headphones).url,products(:usbkey).url].each do |url|
      Event.create(
        :url => url,
        :developer_id => developers(:prixing).id,
        :device_id => devices(:web).id,
        :action => Event::VIEW)
    end
    Event.create!(
      :url => "http://www.toto.fr/productA",
      :developer_id => developers(:prixing).id,
      :device_id => devices(:web).id,
      :action => Event::REQUEST)
    assert_equal 1, Product.viking_pending_batch.count
  end

  test "it shouldn't need a viking check if product has been sent to viking in batch mode" do
    Event.create(
      :url => products(:headphones).url,
      :developer_id => developers(:prixing).id,
      :device_id => devices(:web).id,
      :action => Event::REQUEST)
    products(:headphones).update_attribute :viking_sent_at, Time.now

    assert_equal 0, Product.viking_pending_batch.count
  end

  test "it should get all products which failed Viking extraction" do
    Event.create(
      :url => products(:headphones).url,
      :developer_id => developers(:prixing).id,
      :device_id => devices(:web).id,
      :action => Event::VIEW)
    products(:headphones).update_attribute :viking_failure, true
    assert_equal 1, Product.viking_failure.count
  end

  test "it should get all products needing a Viking check and without failure" do
    [products(:headphones).url,products(:usbkey).url].each do |url|
      Event.create(
        :url => url,
        :developer_id => developers(:prixing).id,
        :device_id => devices(:web).id,
        :action => Event::VIEW)
    end
    products(:headphones).update_attribute :versions_expires_at, Time.now
    assert_equal 2, Product.viking_pending.count
    products(:headphones).update_attribute :viking_failure, true
    assert_equal 1, Product.viking_pending.count
    products(:headphones).update_attribute :versions_expires_at, nil
    assert_equal 2, Product.viking_pending.count
    products(:headphones).update_attribute :versions_expires_at, 1.hour.from_now
    assert_equal 1, Product.viking_pending.count
    products(:headphones).update_attribute :versions_expires_at, 1.day.ago
    assert_equal 2, Product.viking_pending.count
    products(:headphones).update_attribute :muted_until, 1.day.from_now
    assert_equal 1, Product.viking_pending.count
  end  
  
  test "it should get last product needing a Viking check" do
    [products(:headphones).url,products(:usbkey).url].each do |url|
      Event.create(
        :url => url,
        :developer_id => developers(:prixing).id,
        :device_id => devices(:web).id,
        :action => Event::VIEW)
    end
    assert_equal products(:usbkey), Product.viking_pending.first
    products(:usbkey).update_attribute :versions_expires_at, 1.hour.from_now
    assert_equal products(:headphones), Product.viking_pending.first
    products(:headphones).update_attribute :versions_expires_at, 1.hour.from_now
    assert Product.viking_pending.first.nil?
  end

  test "it should get last product needing a Viking check in batch mode" do
    [products(:headphones).url,products(:usbkey).url].each do |url|
      Event.create(
        :url => url,
        :developer_id => developers(:prixing).id,
        :device_id => devices(:web).id,
        :action => Event::REQUEST)
    end
    assert_equal products(:usbkey), Product.viking_pending_batch.first
    products(:usbkey).update_attribute :versions_expires_at, 1.hour.from_now
    assert_equal products(:headphones), Product.viking_pending_batch.first
    products(:headphones).update_attribute :versions_expires_at, 1.hour.from_now
    assert Product.viking_pending_batch.first.nil?
  end

  test "it should expires versions" do
    product = Product.create(:url => 'http://www.rueducommerce.fr/product')
    assert product.versions_expired?
    product.update_attribute :versions_expires_at, 4.hours.from_now
    assert !product.versions_expired?
  end

  test "it should destroy all related events when a product is destroyed" do
    Event.create(
      :url => products(:headphones).url,
      :developer_id => developers(:prixing).id,
      :device_id => devices(:web).id,
      :action => Event::VIEW)
    assert_difference("Event.count",-1) do
      products(:headphones).destroy
    end
  end
  
  test "it should update product and version" do
    product = products(:usbkey)
    product.viking_reset
    product.update_attribute :updated_at, 1.hour.ago
    product.update_attributes(versions:[
      { availability:"out of stock",
        brand: "brand",
        reference: "reference",
        description: "description",
        image_url: "http://www.amazon.fr/image.jpg",
        name: "name",
        price: "10 EUR",
        price_strikeout: "2.58 EUR",
        shipping_info: "info shipping",
        price_shipping: "3.5",
        option1: {"text" => "rouge"},
        option2: {"text" => "34"}
      },
      { availability:"in stock",
        brand: "brand",
        description: "description2",
        reference: "reference4",
        image_url: "http://www.amazon.fr/image2.jpg",
        name: "name2",
        price: "12 EUR",
        price_strikeout: "2.58 EUR",
        shipping_info: "info shipping",
        price_shipping: "3.5",
        option1: {"text" => "blue"},
        option2: {"text" => "34"}
      }]);

    assert_equal "name2", product.name
    assert_equal "brand", product.brand
    assert_equal "reference4", product.reference
    assert_equal "http://www.amazon.fr/image2.jpg", product.image_url
    assert_equal "<p>description2</p>", product.description
    assert_equal 1, product.product_versions.available.count
    assert_equal 12, product.product_versions.available.first.price
    assert product.updated_at > 1.minute.ago
    assert product.versions_expires_at > Time.now
  end

  test "it should set versions_expires_at even if versions are not available" do
    product = products(:usbkey)
    product.update_attribute :versions_expires_at, nil
    product.update_attributes(versions:[{availability:"out of stock"}])

    assert product.versions_expires_at > Time.now
  end  
  
  test "it should reset viking values" do
    product = products(:usbkey)
    product.update_attributes(
      options_completed: true,
      versions:[
        { availability:"in stock",
          brand: "brand",
          reference: "reference",
          description: "description",
          image_url: "http://www.amazon.fr/image.jpg",
          name: "name",
          price: "10 EUR",
          price_strikeout: "2.58 EUR",
          shipping_info: "info shipping",
          price_shipping: "3.5",
          option1: {"text" => "rouge"},
          option2: {"text" => "34"}
        }])

    assert product.reload.options_completed
    assert product.ready?

    product.viking_reset

    assert !product.reload.options_completed
    assert_not_nil product.viking_sent_at
    assert_equal 0, product.product_versions.available.count
  end

  test "it should set previous version as unavailable" do
    product = products(:usbkey)
    product.viking_reset
    product.update_attributes(versions:[
      { availability:"in stock",
        brand: "brand",
        reference: "reference",
        description: "description",
        image_url: "http://www.amazon.fr/image.jpg",
        name: "name",
        price: "10 EUR",
        price_strikeout: "2.58 EUR",
        shipping_info: "info shipping",
        price_shipping: "3.5",
        option1: {"text" => "rouge"},
        option2: {"text" => "34"}
      }])
    product.viking_reset
    product.update_attributes(versions:[
      { availability:"in stock",
        brand: "brand",
        reference: "reference",
        description: "description",
        image_url: "http://www.amazon.fr/image.jpg",
        name: "name",
        price: "10 EUR",
        price_strikeout: "2.58 EUR",
        shipping_info: "info shipping",
        price_shipping: "3.5",
        option1: {"text" => "bleu"},
        option2: {"text" => "34"}
      }])
      
    assert_equal 1, product.reload.product_versions.available.count
    assert_equal [false, true].to_set, product.product_versions.map(&:available).to_set
  end
  
  test "it should reset viking_failure if correct version is added" do
    product = products(:usbkey)
    product.update_attribute :viking_failure, true
    product.update_attributes(versions:[
      { availability:"in stock",
        brand: "brand",
        description: "description",
        image_url: "http://www.amazon.fr/image.jpg",
        name: "name",
        price: "10 EUR",
        price_strikeout: "2.58 EUR",
        shipping_info: "free shipping",
        price_shipping: "3.5"
      }]);

     assert !product.viking_failure
  end  

  test "it should use availability if shipping info is blank" do
    product = products(:headphones)
    product.update_attribute :viking_failure, true
    product.update_attributes(versions:[
      { availability:"in stock",
        brand: "brand",
        description: "description",
        image_url: "http://www.amazon.fr/image.jpg",
        name: "name",
        price: "10 EUR",
        price_strikeout: "2.58 EUR",
        price_shipping: "3.5"
      }]);

     assert !product.viking_failure
     assert_equal "in stock", product.product_versions.first.shipping_info
  end  

  test "it shouldn't set viking_failure if availability is false and anything is missing" do
    product = products(:headphones)
    
    product.update_attributes(versions:[
      { availability:"out of stock",
        image_url: "http://www.amazon.fr/image.jpg",
        name: "name"
      }]);
    assert !product.viking_failure

    product.update_attributes(versions:[
      { availability:"out of stock",
      }]);
    assert !product.viking_failure

    product.update_attributes(versions:[
      { name: "name",
        image_url: "http://www.amazon.fr/image.jpg",
        price: "10 EUR",
        price_strikeout: "2.58 EUR",
        shipping_info: "En stock"
      }]);
    assert product.viking_failure
  end 
  
  test "it should clear viking_failure when muted" do
     product = products(:headphones)
     assert !product.mute?
     
     product.update_attributes(versions:[
      { availability:"in stock",
        name: "name"
      }]);
     assert product.viking_failure
     
     product.update_attribute :muted_until, 1.year.from_now
     assert product.mute?
     assert !product.viking_failure
  end

  test "it should pre process versions using merchant helper" do
    product = products(:nounours)
    product.update_attributes(versions:[
      { availability:"in stock",
        brand: "brand",
        description: "description",
        image_url: "http://www.amazon.fr/image.jpg",
        name: "name",
        price: "10 EUR",
        price_strikeout: "2.58 EUR"
      }]);

    assert !product.viking_failure
    assert_equal 7.20, product.product_versions.first.price_shipping
  end  

  test "it should fail viking if shipping price is blank and no default shipping price is set for merchant" do
    product = products(:headphones)
    product.update_attributes(versions:[
      { availability:"in stock",
        brand: "brand",
        description: "description",
        image_url: "http://www.amazon.fr/image.jpg",
        name: "name",
        price: "10 EUR",
        price_strikeout: "2.58 EUR"
      }]);

     assert product.viking_failure
  end

  test "it should set ready" do
    product = products(:usbkey)
    product.viking_failure = true
    assert !product.ready?

    product.viking_failure = false
    assert !product.ready?

    product.versions_expires_at = 1.hour.from_now
    assert product.ready?
  end

  test "it should overwrite version without option when receiving first version with options" do
    product = Product.create!(url:"http://www.amazon.fr/toto")
    assert_equal 1, product.product_versions.count

    assert_difference("ProductVersion.count", 0) do
      product.update_attributes(versions:[
        { option1: {"text" => "rouge"},
          option2: {"text" => "34"}
        }
      ])
    end

    assert_equal "rouge", JSON.parse(product.reload.product_versions.first.option1)["text"]
  end

  test "it shouldn't create new version when updating" do
    product = Product.create!(url:"http://www.amazon.fr/toto")

    assert_difference("ProductVersion.count", 1) do
      product.update_attributes(versions:[
        { option1: {"text" => "rouge"},
          option2: {"text" => "34"}
        },
        { option1: {"text" => "rouge"},
          option2: {"text" => "35"}
        }
      ])
    end

    assert_difference("ProductVersion.count", 0) do
      product.update_attributes(versions:[
        { availability:"in stock",
          brand: "brand",
          reference: "reference",
          description: "description",
          image_url: "http://www.amazon.fr/image.jpg",
          name: "name",
          price: "10 EUR",
          price_strikeout: "2.58 EUR",
          shipping_info: "info shipping",
          price_shipping: "3.5",
          option1: {"text" => "rouge"},
          option2: {"text" => "34"}
        },
        { availability:"in stock",
          brand: "brand",
          reference: "reference",
          description: "description",
          image_url: "http://www.amazon.fr/image.jpg",
          name: "name",
          price: "10 EUR",
          price_strikeout: "2.58 EUR",
          shipping_info: "info shipping",
          price_shipping: "3.5",
          option1: {"text" => "rouge"},
          option2: {"text" => "35"}
        }
      ])
    end
  end
end