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

  test "it should create collection item from feed data" do
    feed = example_feed

    item = CollectionItem.new(collection_id:@collection.id, feed:feed)
    assert item.save

    product = Product.fetch("http://www.amazon.fr/dp/2821201710")
    assert !product.ready?
  end

  test "it should create collection item from feed data without viking" do
    feed = example_feed
    feed[:saturn] = "0"

    item = CollectionItem.new(collection_id:@collection.id, feed:feed)
    assert item.save

    product = Product.fetch("http://www.amazon.fr/dp/2821201710")
    assert_equal 1, product.product_versions.available.count
    assert product.ready?
    assert product.options_completed?
    assert product.versions_expires_at.to_i > 29.days.from_now.to_i

    version = product.product_versions.first
    assert_equal "Barbapapa", version.name
    assert_equal "Annette Tison", version.brand
    assert_equal "http://ecx.images-amazon.com/images/I/41VYewm9YrL.jpg", version.image_url
    assert_equal "<p>Pages: 10, Album, Les Livres du Dragon d'Or</p>", version.description
    assert_equal 4.28, version.price
    assert_equal 5.90, version.price_shipping
    assert_equal "ok", version.shipping_info
    assert_equal "En stock", version.availability_info
  end

  def example_feed
    {
      brand:"Annette Tison",
      name:"Barbapapa",
      description:"Pages: 10, Album, Les Livres du Dragon d'Or",
      product_url:"http://www.amazon.fr/dp/2821201710",
      price:428,
      price_shipping:590,
      shipping_info:"ok",
      image_url:"http://ecx.images-amazon.com/images/I/41VYewm9YrL.jpg",
      saturn:"1"
   }
  end
end