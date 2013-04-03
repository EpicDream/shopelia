require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :merchants, :products
  
  test "it should create product" do
    product = Product.new(
      :name => 'Product',
      :merchant_id => merchants(:rueducommerce).id,
      :url => 'http://www.rueducommerce.fr/product',
      :image_url => 'http://www.rueducommerce.fr/image')
    assert product.save, product.errors.full_messages.join(",")
  end

end
