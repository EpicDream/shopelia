require 'test_helper'

class ProductImageTest < ActiveSupport::TestCase

  setup do
    @product = product_versions(:usbkey)
  end

  test "it should create product image" do
    image = ProductImage.new(product_version_id:@product.id,url:"http://ecx.images-amazon.com/images/I/81zxTIH-A3L._SX342_.jpg")
    assert image.save

    assert_equal "342x281", image.size
  end
end