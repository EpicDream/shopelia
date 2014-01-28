require 'test__helper'

class FlinkerTest < ActiveSupport::TestCase
  fixtures :all
  
  test "it should create flinker" do
    new_flinker
    assert @flinker.save

    assert_equal 0, ActionMailer::Base.deliveries.count, "a confirmation email shouldn't have been sent"
  end

  test "it should create infinitely flinker with email test@flink.io" do
    new_flinker
    assert @flinker.save

    new_flinker
    assert @flinker.save
  end

  test "it should auto follow staff picked flinkers" do 
    new_flinker
    assert_difference "FlinkerFollow.count", 2 do
      @flinker.save
    end
  end
  
  test "when name or url change, it should be changed on blog" do
    flinker = flinkers(:elarch)
    blog = blogs(:betty) and blog.flinker_id = flinker.id
    assert blog.save
    
    assert flinker.update_attributes(name:"Toto", url:"http://www.blagues.com")
    blog.reload

    assert_equal "Toto", flinker.name
    assert_equal "http://www.blagues.com", flinker.url
    assert_equal "Toto", blog.name
    assert_equal "http://www.blagues.com", blog.url
  end
  
  private

  def new_flinker
    @flinker = Flinker.new(
      name:"Name",
      url:"http://www.url.to",
      is_publisher:true,
      email:"test@flink.io",
      password:"password",
      password_confirmation:"password")
  end  
  
end