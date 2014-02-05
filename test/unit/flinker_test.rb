require 'test_helper'

class FlinkerTest < ActiveSupport::TestCase
  
  setup do
    @flinker = new_flinker
  end
  
  test "it should create flinker" do
    assert @flinker.save

    assert_equal 0, ActionMailer::Base.deliveries.count, "a confirmation email shouldn't have been sent"
  end

  test "it should create infinitely flinker with email test@flink.io" do
    1.upto(2) {
      assert new_flinker.save
    }
  end

  test "it should auto follow staff picked flinkers of same country" do 
    assert_difference "FlinkerFollow.count", 2 do
      @flinker.save
    end
  end
  
  test "when name change, it should be changed on blog" do
    flinker = flinkers(:elarch)
    blog = blogs(:betty) and blog.flinker_id = flinker.id
    
    assert blog.save
    assert flinker.update_attributes(name:"Toto") and blog.reload
    assert_equal "Toto", flinker.name
    assert_equal "Toto", blog.name
  end
  
  test "assign country from country_iso transcient attribute" do
    flinker = Flinker.new(email:"test@flink.io", name:"flink", password:"toto1234", password_confirmation:"toto1234", country_iso:"fr")
    
    assert flinker.save
    assert_equal countries(:france), flinker.country
  end
  
  test "of_country scope case insensitive on iso code" do
    assert_equal Flinker.of_country("fr"), Flinker.of_country("FR") 
  end
  
  private

  def new_flinker
    Flinker.new(
      name:"Name",
      url:"http://www.url.to",
      is_publisher:true,
      email:"test@flink.io",
      password:"password",
      country_id:countries(:france).id,
      password_confirmation:"password")
  end  
  
end