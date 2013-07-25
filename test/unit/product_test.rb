# -*- encoding : utf-8 -*-
require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  
  test "it should create product" do
    product = Product.new(
      :name => 'Product',
      :merchant_id => merchants(:rueducommerce).id,
      :url => 'http://www.rueducommerce.fr/product',
      :image_url => 'http://www.rueducommerce.fr/image')
    assert product.save, product.errors.full_messages.join(",")
    assert_equal 1, product.product_versions.count
    
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
    assert_equal "http://www.amazon.fr/Brother-Telecopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO", product.url
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
    product.product_versions.first.update_attribute :price, nil    
    product.assess_versions
    assert product.viking_failure
  end
  
  test "it should get all products needing a Viking check" do
    Event.from_urls(
      :urls => [products(:headphones).url,products(:usbkey).url],
      :developer_id => developers(:prixing).id,
      :action => Event::VIEW)
    assert_equal 2, Product.viking_pending.count
    products(:headphones).update_attribute :versions_expires_at, 1.hour.from_now
    assert_equal 1, Product.viking_pending.count
  end

  test "it should get all products which failed Viking extraction" do
    Event.from_urls(
      :urls => [products(:headphones).url],
      :developer_id => developers(:prixing).id,
      :action => Event::VIEW)
    products(:headphones).update_attribute :viking_failure, true
    assert_equal 1, Product.viking_failure.count
  end

  test "it should get all products needing a Viking check and without failure" do
    Event.from_urls(
      :urls => [products(:headphones).url,products(:usbkey).url],
      :developer_id => developers(:prixing).id,
      :action => Event::VIEW)
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
  end  
  
  test "it should get last product needing a Viking check" do
    Event.from_urls(
      :urls => [products(:headphones).url,products(:usbkey).url],
      :developer_id => developers(:prixing).id,
      :action => Event::VIEW)
    assert_equal products(:usbkey), Product.viking_shift
    products(:usbkey).update_attribute :versions_expires_at, 1.hour.from_now
    assert_equal products(:headphones), Product.viking_shift
    products(:headphones).update_attribute :versions_expires_at, 1.hour.from_now
    assert Product.viking_shift.nil?
  end

  test "it should expires versions" do
    product = Product.create(:url => 'http://www.rueducommerce.fr/product')
    assert product.versions_expired?
    product.update_attribute :versions_expires_at, 4.hours.from_now
    assert !product.versions_expired?
  end

  test "it should destroy all related events when a product is destroyed" do
    Event.from_urls(
      :urls => [products(:headphones).url],
      :developer_id => developers(:prixing).id,
      :action => Event::VIEW)
    assert_difference("Event.count",-1) do
      products(:headphones).destroy
    end
  end
  
  test "it should update product and version" do
    product = products(:usbkey)
    product.update_attributes(versions:[
      { availability:"in stock",
        brand: "brand",
        description: "description",
        image_url: "http://www.amazon.fr/image.jpg",
        name: "name",
        price: "10 EUR",
        price_strikeout: "2.58 EUR",
        shipping_info: "info shipping",
        price_shipping: "3.5",
        color: "blue",
        size: "4"
      },
      { availability:"out of stock",
        brand: "brand",
        description: "description2",
        image_url: "http://www.amazon.fr/image2.jpg",
        name: "name2",
        price: "12 EUR",
        price_strikeout: "2.58 EUR",
        shipping_info: "info shipping",
        price_shipping: "3.5",
        color: "blue",
        size: "4"
      }]);

     assert_equal "name", product.name
     assert_equal "http://www.amazon.fr/image.jpg", product.image_url
     assert_equal "description", product.description
     assert_equal 2, product.product_versions.count
     assert_equal [10.0,12.0].to_set, product.product_versions.map(&:price).to_set
     assert_equal [true, false].to_set, product.product_versions.map(&:available).to_set
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

end
