require 'test_helper'

class Api::Flink::Hashtags::LooksControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @flinker = flinkers(:fanny)
    sign_in @flinker
    rewrite_sql() #dont like that => postgres local
  end
  
  test "get looks with comments containing any given hashtags" do
    Comment.update_all(body:"wha #beautiful !")
    get :index, format: :json, hashtag:"#beautiful"
    
    assert_response :success
    
    looks = json_response["looks"]
    assert_equal 1, looks.count
  end
  
  private
  
  def rewrite_sql
    Look.instance_eval do
      scope :with_comment_matching, ->(pattern) {
        joins(:comments).where('comments.body like ?', "%#{pattern}%")
      }
    end
  end
  
end