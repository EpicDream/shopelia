require 'test_helper'

class Api::Viking::ProductsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    Product.destroy_all
    @developer = developers(:prixing)
  end

  test "it should send back first 100 products requiring a Viking check" do
    populate_events
    get :index
    
    assert_response :success   
    assert_equal 2, json_response.count

    get :index
    assert_equal 0, json_response.count    
  end

  test "it should send back first 100 products requiring a Viking check in batch mode" do
    populate_events
    get :index, batch:true
    
    assert_response :success   
    assert_equal 1, json_response.count

    get :index, batch:true
    assert_equal 0, json_response.count    
  end
  
  test "it should send back first product in queue waiting for a Viking check" do
    populate_events
    get :shift
    
    assert_response :success   
    assert_match /amazon.fr\/2/, json_response["url"]

    get :shift
    
    assert_response :success   
    assert_match /amazon.fr\/1/, json_response["url"]
  end

  test "it should send back first product in queue waiting for a Viking check in batch mode" do
    populate_events
    get :shift, batch:true
    
    assert_response :success   
    assert_match /priceminister/, json_response["url"]

    get :shift, batch:true
    assert json_response.empty?
  end
  
  test "it should send empty hash if not product waiting" do
    get :shift
    
    assert_response :success
    assert json_response.empty?
  end

  test "it should update product with versions" do
    populate_events
    product = Product.first
    put :update, id:product.id, versions:[
      { availability:"in stock",
        brand: "brand",
        description: "description",
        image_url: "http://www.amazon.fr/image.jpg",
        name: "name",
        price: "2,26 EUR",
        price_strikeout: "2.58 EUR",
        shipping_info: "info shipping",
        price_shipping: "3.5",
        option1: {"text" => "rouge"},
        option2: {"text" => "34"}
      }], options_completed:true, format: :json
    
    assert_response 204
    assert !product.reload.viking_failure
    assert product.options_completed
  end
  
  test "it should set product as viking failed if missing any main element" do
    populate_events
    product = Product.first
    product.product_versions.destroy_all
    put :update, id:product.id, versions:[
      { availability:"en stock",
        brand: "brand",
        description: "description",
        image_url: "http://www.amazon.fr/image.jpg",
        price_strikeout: "2.58 EUR",
        shipping_info: "info shipping",
        price_shipping: "3.5",
      }], format: :json
    
    assert_response 204
    
    assert product.reload.viking_failure
  end

  test "it should set product as viking failed if empty versions" do
    populate_events
    product = Product.first
    put :update, id:product.id, versions:nil, format: :json
    assert_response 204
    
    assert product.reload.viking_failure
    assert !product.versions_expires_at.nil?
  end

  test "it should send all failed viking products" do
    populate_events
    product = Product.find_by_url("http://www.amazon.fr/1")
    product.update_attribute :viking_failure, true
    get :failure
    
    assert_response :success
    assert_equal 1, json_response.count
  end

  test "it should send next failed viking products" do
    populate_events
    product = Product.find_by_url("http://www.amazon.fr/1")
    product.update_attribute :viking_failure, true
    get :failure_shift
    
    assert_response :success
    assert_match /amazon.fr\/1/, json_response["url"]
  end
  
  test "it should send alive data (for Viking monitoring)" do
    populate_events
    event = Event.last
    event.update_attribute :created_at, 5.minutes.ago
    event.product.update_attribute :updated_at, 10.minutes.ago
    
    get :alive
    assert_response :success
    assert_equal 0, json_response["alive"]
    
    event.product.update_attribute :updated_at, Time.now
    
    get :alive
    assert_response :success
    assert_equal 1, json_response["alive"]
  end
  
  test "it should reset versions when sending product to viking" do
    populate_events
    product = Product.find_by_url("http://www.amazon.fr/1")

    put :update, id:product.id, versions:[
      { availability:"in stock",
        brand: "brand",
        description: "description",
        image_url: "http://www.amazon.fr/image.jpg",
        name: "name",
        price: "2,26 EUR",
        price_strikeout: "2.58 EUR",
        shipping_info: "info shipping",
        price_shipping: "3.5",
        option1: {"text" => "rouge"},
        option2: {"text" => "34"}
      }], format: :json

    assert_equal 1, product.reload.product_versions.available.count
    product.update_attribute :versions_expires_at, 12.hours.ago

    get :index

    assert_equal 0, product.reload.product_versions.available.count
    
    put :update, id:product.id, versions:[
      { availability:"in stock",
        brand: "brand",
        description: "description",
        image_url: "http://www.amazon.fr/image.jpg",
        name: "name",
        price: "2,26 EUR",
        price_strikeout: "2.58 EUR",
        shipping_info: "info shipping",
        price_shipping: "3.5",
        option1: {"text" => "rouge"},
        option2: {"text" => "35"}
      }], format: :json

    assert_equal 1, product.reload.product_versions.available.count
  end

  private
  
  def populate_events
    Event.from_urls(
      :urls => ["http://www.amazon.fr/1","http://www.amazon.fr/2"],
      :developer_id => @developer.id,
      :device_id => devices(:web).id,
      :action => Event::VIEW)
    Event.from_urls(
      :urls => ["http://www.amazon.fr/1","http://www.amazon.fr/2"],
      :developer_id => @developer.id,
      :device_id => devices(:web).id,
      :action => Event::CLICK)
    Event.from_urls(
      :urls => ["http://www.priceminister.com/my_product"],
      :developer_id => @developer.id,
      :device_id => devices(:web).id,
      :action => Event::REQUEST)
  end
end