require 'test_helper'

class Api::Viking::ProductsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @developer = developers(:prixing)
  end

  test "it should send back first 100 products requiring a Viking check" do
    populate_events
    get :index
    
    assert_response :success   
    assert_equal 2, json_response.count
  end
  
  test "it should send back first product in queue waiting for a Viking check" do
    populate_events
    get :shift
    
    assert_response :success   
    assert_match /amazon.fr\/2/, json_response["url"]
  end
  
  test "it should send 404 if not product waiting" do
    get :shift
    
    assert_response :not_found
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
        shipping_price: "3.5",
        color: "blue",
        size: "4"
      }], format: :json
    
    assert_response 204
    assert !product.viking_failure
  end
  
  test "it should set product as viking failed if missing any main element" do
    populate_events
    product = Product.first
    put :update, id:product.id, versions:[
      { availability:"in stock",
        brand: "brand",
        description: "description",
        image_url: "http://www.amazon.fr/image.jpg",
        price_strikeout: "2.58 EUR",
        shipping_info: "info shipping",
        shipping_price: "3.5",
      }], format: :json
    
    assert_response 204
    
    assert product.reload.viking_failure
  end

  private
  
  def populate_events
    Event.from_urls(
      :urls => ["http://www.amazon.fr/1","http://www.amazon.fr/2"],
      :developer_id => @developer.id,
      :action => Event::VIEW)
  end
  
end

