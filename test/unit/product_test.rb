# -*- encoding : utf-8 -*-
require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :merchants, :products, :developers
  
  test "it should create product" do
    product = Product.new(
      :name => 'Product',
      :merchant_id => merchants(:rueducommerce).id,
      :url => 'http://www.rueducommerce.fr/product',
      :image_url => 'http://www.rueducommerce.fr/image')
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

  test "it should monetize url" do
    product = Product.new(:url => "http://www.amazon.fr/Brother-Telecopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=prixing-web-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO")
    assert product.save, product.errors.full_messages.join(",")
    assert_equal "http://www.amazon.fr/Brother-Telecopieur-photocopieuse-transfert-thermique/dp/B0006ZUFUO?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&tag=shopelia-21&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B0006ZUFUO", product.url
  end

  test "it should fetch existing product" do
    assert_equal products(:headphones), Product.fetch("http://www.rueducommerce.fr/productB")
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
  
  test "it should get all products needing a Viking check" do
    Event.from_urls(
      :urls => [products(:headphones).url,products(:usbkey).url],
      :developer_id => developers(:prixing).id,
      :action => Event::VIEW)
    assert_equal 2, Product.viking_pending.count
    products(:headphones).update_attribute :last_checked_at, 1.minute.ago
    assert_equal 1, Product.viking_pending.count
  end
  
  test "it should get last product needing a Viking check" do
    Event.from_urls(
      :urls => [products(:headphones).url,products(:usbkey).url],
      :developer_id => developers(:prixing).id,
      :action => Event::VIEW)
    assert_equal products(:usbkey), Product.viking_shift
    products(:usbkey).update_attribute :last_checked_at, 1.minute.ago
    assert_equal products(:headphones), Product.viking_shift
    products(:headphones).update_attribute :last_checked_at, 1.minute.ago
    assert Product.viking_shift.nil?
  end

end
