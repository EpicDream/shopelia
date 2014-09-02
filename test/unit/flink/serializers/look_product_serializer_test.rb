require 'test_helper'

class LookProductSerializerTest < ActiveSupport::TestCase
  
  setup do
    @look = looks(:agadir)
    @product = VendorProduct.create(url: "http://3suisses.com/jupette", vendor: "pureshopping", similar: true)
    @look_product = LookProduct.create(look_id: @look.id, brand: "Zara", code: "jean")
  end
  
  test "serialize look product with vendor product" do
    @look_product.vendor_products << @product
    product = LookProductSerializer.new(@look_product).as_json[:look_product]

    assert_equal @look_product.uuid, product[:uuid]
    assert_equal @look_product.brand, product[:brand]
    assert_equal "Jean", product[:code]
    assert_equal "http://3suisses.com/jupette", product[:products].first[:url]
    assert product[:products].first[:similar]
  end
  
  test "code with nil code" do
    @look_product.update_attributes(code: nil)

    product = LookProductSerializer.new(@look_product).as_json[:look_product]

    assert_equal "", product[:code]
  end
  
  test "code with translation missing" do
    @look_product.update_attributes(code: "noexistentcode")

    product = LookProductSerializer.new(@look_product).as_json[:look_product]

    assert_equal "", product[:code]
  end
  
end
