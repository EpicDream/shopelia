require 'test_helper'

class Api::Flink::Mailjet::UnsubscribesControllerTest < ActionController::TestCase     

  test "set flinker newsletter to false when mailjet unsub triggered" do
    flinker = flinkers(:betty)
    assert flinker.newsletter

    post :create, payload, format: :json
    
    assert_response :ok
    assert !flinker.reload.newsletter
  end
  
  test "user not found by email" do

    post :create, payload("toto@flink.io"), format: :json
    
    assert_response :ok
  end
  
  
  private
  
  def payload email="betty@flink.com"
    { "event" => "unsub", 
      "unsubscribe"=> { "event" => "unsub", "time" => 1400493885, "email" => email }
    }
  end
end