require 'test_helper'

class FlinkerTest < ActiveSupport::TestCase

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