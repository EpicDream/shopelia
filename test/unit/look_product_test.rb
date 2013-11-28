require 'test_helper'

class LookProductTest < ActiveSupport::TestCase

  setup do
    @look = looks(:agadir)
  end

  test "it should create look product item" do
    item = LookProduct.new(look_id:@look.id, product_id:products(:headphones).id)
    assert item.save
  end

  test "it should create look product item from url" do
    assert_difference ["Product.count", "Product.count"] do
      item = LookProduct.new(
        look_id:@look.id, 
        url:"http://www.amazon.fr/gp/product/1")

      assert item.save
    end
  end

  test "it should generate event" do
    assert_difference ["EventsWorker.jobs.count"] do
      item = LookProduct.create(
        look_id:@look.id, 
        url:"http://www.amazon.fr/gp/product/1")
    end
  end

  test "it shouldn't create association from bad url" do
    item = LookProduct.new(
      look_id:@look.id, 
      url:"invalid")

    assert !item.save
    assert_equal I18n.t('app.collections.add.invalid_url'), item.errors.full_messages.first
  end
end