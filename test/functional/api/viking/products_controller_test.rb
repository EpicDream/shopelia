require 'test_helper'

class Api::Viking::ProductsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :developers
  
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

  private
  
  def populate_events
    Event.from_urls(
      :urls => ["http://www.amazon.fr/1","http://www.amazon.fr/2"],
      :developer_id => @developer.id,
      :action => Event::VIEW)
  end
  
end

