require 'test_helper'

class PspTest < ActiveSupport::TestCase
  fixtures :psps

  test "it should create psp" do
    psp = Psp.new(:name => 'Lydia')
    assert psp.save
  end
  
  test "it shouldn't allow duplicate name" do
    psp = Psp.new(:name => 'Leetchi')
    assert !psp.save
  end

end
