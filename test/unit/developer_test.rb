require 'test_helper'

class DeveloperTest < ActiveSupport::TestCase
  
  test "it should create new developer" do
    dev = Developer.new(:name => 'Eric')
    assert dev.save, dev.errors.full_messages.join(",")
    assert dev.api_key
  end
  
  test "it shouldn't allow duplicate name or api_key" do
    dev = Developer.new(:name => 'Prixing')
    assert !dev.save
  end
  
end
