require 'test_helper'

class PspUserTest < ActiveSupport::TestCase
  fixtures :users, :psps, :psp_users

  test "it should create psp user" do
    user = PspUser.new(
      :user_id => users(:elarch).id,
      :psp_id => psps(:tunz).id,
      :remote_user_id => 2)
    assert user.save
  end
  
  test "it should have unicity of users for a psp" do
    user = PspUser.new(
      :user_id => users(:elarch).id,
      :psp_id => psps(:leetchi).id,
      :remote_user_id => 2)
    assert !user.save
  end

  test "it should have unicity of object_id for a psp" do
    user = PspUser.new(
      :user_id => users(:manu).id,
      :psp_id => psps(:leetchi).id,
      :remote_user_id => 1)
    assert !user.save
  end

end
