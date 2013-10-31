# -*- encoding : utf-8 -*-
require 'test_helper'

class ProductSerializerTest < ActiveSupport::TestCase
  
  setup do
    @product = products(:usbkey)
    @product.update_attribute :versions_expires_at, 4.hours.from_now
  end
  
  test "it should correctly serialize product" do
    product_serializer = ProductSerializer.new(@product)
    hash = product_serializer.as_json
      
    assert_equal @product.id, hash[:product][:id]
    assert_equal @product.name, hash[:product][:name]
    assert_equal @product.brand, hash[:product][:brand]
    assert_equal @product.reference, hash[:product][:reference]
    assert_equal @product.url, hash[:product][:url]
    assert_equal @product.image_url, hash[:product][:image_url]
    assert_equal @product.description, hash[:product][:description]
    assert_equal @product.merchant.name, hash[:product][:merchant][:name]
    assert_equal @product.product_master_id, hash[:product][:master_id]
    assert_equal 7.0, hash[:product][:price]
    assert_equal "300x225", hash[:product][:image_size]
    assert_equal 1, hash[:product][:ready]
    assert_equal 1, hash[:product][:options_completed]
    assert_equal 1, hash[:product][:versions].count
    
    product_versions(:usbkey).update_attribute :available, false
    @product.update_attribute :versions_expires_at, 1.hour.ago
    product_serializer = ProductSerializer.new(@product)
    hash = product_serializer.as_json
    
    assert_equal 0, hash[:product][:versions].count
    assert_equal 0, hash[:product][:ready]

    @product.update_attribute :versions_expires_at, 4.hours.from_now
    @product.update_attribute :viking_failure, true
    product_serializer = ProductSerializer.new(@product)
    hash = product_serializer.as_json
    
    assert_equal 0, hash[:product][:ready]

    @product.update_attribute :versions_expires_at, nil
    product_serializer = ProductSerializer.new(@product)
    hash = product_serializer.as_json
    
    assert_equal 0, hash[:product][:ready]
  end

  test "it should serialize product with cashfront value" do
    product_serializer = ProductSerializer.new(products(:dvd), scope:{developer:developers(:prixing)})
    hash = product_serializer.as_json

    assert_equal 1, hash[:product][:versions].count
    version = hash[:product][:versions].first
    assert_equal 0.30, version[:cashfront_value]
  end

  test "it should serialize short version" do
    product_serializer = ProductSerializer.new(@product, scope:{short:true})
    hash = product_serializer.as_json

    assert hash[:product][:description].nil?
    assert hash[:product][:versions].nil?
  end
end