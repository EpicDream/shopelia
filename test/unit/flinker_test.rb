require 'test_helper'

class FlinkerTest < ActiveSupport::TestCase

  test "it should create flinker" do
    flinker = Flinker.new(
      name:"Name",
      url:"http://www.url.to",
      is_publisher:true,
      email:"email@flinker.io",
      password:"password",
      password_confirmation:"password")
    assert flinker.save

    assert_equal 0, ActionMailer::Base.deliveries.count, "a confirmation email shouldn't have been sent"
  end
end