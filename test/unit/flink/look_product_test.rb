require 'test_helper'

class LookProductTest < ActiveSupport::TestCase

  setup do
    @look = looks(:agadir)
    LookProduct.any_instance.stubs(:generate_event)
  end

  test "it should create look product item" do
    item = LookProduct.new(look_id:@look.id, product_id:products(:headphones).id, code:"bag")
    assert item.save
  end

  test "it should create look product from brand" do
    item = LookProduct.new(look_id:@look.id, brand:"test", code:"code")
    assert item.save
  end

  test "it shouldn't create empty look product" do
    item = LookProduct.new(look_id:@look.id)
    assert !item.save
  end    

  test "it should create look product item from url" do
    assert_difference ["Product.count", "Product.count"] do
      item = LookProduct.new(
        look_id:@look.id, 
        code:"bag",
        url:"http://www.amazon.fr/gp/product/1")

      assert item.save
    end
  end

  test "it shouldn't create association from bad url" do
    item = LookProduct.new(
      look_id:@look.id, 
      url:"invalid")

    assert !item.save
    assert_equal I18n.t('app.collections.add.invalid_url'), item.errors.full_messages.first
  end

  test "it should create item from feed data" do
    feed = example_feed

    item = LookProduct.new(look_id:@look.id, feed:feed, code:"bag")
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
  
  test "when look product is updated, look must be touched(for api updated looks since)" do
    assert_change(@look, :updated_at, :>) { 
      @look.look_products << LookProduct.new(look_id:@look.id, feed:example_feed, code:"bag")
    }
    assert_change(@look, :updated_at, :>) { 
      @look.look_products.first.update_attributes(brand:"toto")
    }
  end
  
  test "uniqueness on code-brand for a given look" do
    assert_difference('LookProduct.count') do
      2.times { LookProduct.create(code:"ET", brand:"H", look_id:@look.id)}
    end
  end
  
  test "create hashtag from brand and code if not exists and assign to look" do
    assert_difference('Hashtag.count', 3) do
      2.times { LookProduct.create(code:"handkerchief", brand:"channel", look_id:@look.id)}
    end
    @look.reload
    
    assert_equal 3, @look.hashtags.count
    assert_equal ["Handkerchief", "channel", "Pochette"].to_set, @look.hashtags.map(&:name).to_set
  end
  
  test "create hashtag from brand and code if not exists and assign to look with space separated brand name" do
    Hashtag.create!(name:"philip lim")
    assert_difference('Hashtag.count', 2) do
      2.times { LookProduct.create(code:"handkerchief", brand:"philip lim", look_id:@look.id)}
    end
    @look.reload
    
    assert_equal 3, @look.hashtags.count
    assert_equal ["Handkerchief", "philiplim", "Pochette"].to_set, @look.hashtags.map(&:name).to_set
  end
  
  test "change brand should update related hashtag name if name not already taken" do
    product = LookProduct.create(code:"handkerchief", brand:"Magic Brand", look_id:@look.id)
    hashtag = Hashtag.find_by_name("MagicBrand")
    
    assert_no_difference('Hashtag.count') do
      product.update_attributes(brand:"New Brand")
    end
    
    assert_equal "NewBrand", hashtag.reload.name
  end
  
  test "change brand should assign new hashtag looks, and destroy old hashtag" do
    hashtag = Hashtag.create!(name:"NewBrand")
    
    product = LookProduct.create(code:"handkerchief", brand:"Magic Brand", look_id:@look.id)
    
    assert_difference('Hashtag.count', -1) do
      product.update_attributes(brand:"New Brand")
    end
    
    @look.reload
    
    assert_equal 3, @look.hashtags.count
    assert @look.hashtags.include?(hashtag)
  end
  
  test "generate uuid before create" do
    product = LookProduct.create(code:"handkerchief", brand:"Magic Brand", look_id:@look.id)
    assert product.reload.uuid.length == 8
  end
  
  private

  def example_feed
    {
      brand:"Annette Tison",
      name:"Barbapapa",
      description:"Pages: 10, Album, Les Livres du Dragon d'Or",
      product_url:"http://www.amazon.fr/dp/2821201710",
      price:428,
      price_shipping:590,
      shipping_info:"ok",
      image_url:"http://ecx.images-amazon.com/images/I/41VYewm9YrL.jpg"
   }
  end
end