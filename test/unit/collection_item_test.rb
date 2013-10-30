require 'test_helper'

class CollectionItemTest < ActiveSupport::TestCase

  setup do
    @collection = collections(:got)
  end

  test "it should create collection item" do
    r = CollectionItem.new(collection_id:@collection.id, product_version_id:product_versions(:headphones).id)
    assert r.save
  end

  test "it shouldn't associate same product twice to collection" do
    r = CollectionItem.new(collection_id:@collection.id, product_version_id:product_versions(:usbkey).id)
    assert !r.save
  end

  test "it should create association from url" do
    assert_difference ["Product.count", "ProductVersion.count"] do
      item = CollectionItem.new(
        collection_id:@collection.id, 
        url:"http://www.amazon.fr/gp/product/1")

      assert item.save
    end
  end

  test "it shouldn't create association from bad url" do
    item = CollectionItem.new(
      collection_id:@collection.id, 
      url:"invalid")

    assert !item.save
    assert_equal I18n.t('app.collections.add.invalid_url'), item.errors.full_messages.first
  end 
end