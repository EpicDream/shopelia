require 'test_helper'

class CollectionItemTest < ActiveSupport::TestCase

  setup do
    @collection = collections(:got)
  end

  test "it should create collection item" do
    r = CollectionItem.new(collection_id:@collection.id, product_id:products(:headphones).id)
    assert r.save
  end

  test "it shouldn't associate same product twice to collection" do
    r = CollectionItem.new(collection_id:@collection.id, product_id:products(:usbkey).id)
    assert !r.save
  end

  test "it should create association from url" do
    assert_difference ["Product.count", "Product.count"] do
      item = CollectionItem.new(
        collection_id:@collection.id, 
        url:"http://www.amazon.fr/gp/product/1")

      assert item.save
    end
  end

  test "it should generate event" do
    assert_difference ["EventsWorker.jobs.count"] do
      item = CollectionItem.create(
        collection_id:@collection.id, 
        url:"http://www.amazon.fr/gp/product/1")
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