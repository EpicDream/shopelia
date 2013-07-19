require 'test_helper'

class UrlMatcherTest < ActiveSupport::TestCase
  
  test "it should create url matcher" do
    matcher = UrlMatcher.new(
      :url => "http://www.toto.fr/xxx",
      :canonical => "http://www.toto.fr")
    assert matcher.save
    
    matcher = UrlMatcher.new(
      :url => "http://www.toto.fr/yyy",
      :canonical => "http://www.toto.fr")
    assert matcher.save
    
    matcher = UrlMatcher.new(
      :url => "http://www.toto.fr/yyy",
      :canonical => "http://www.toto.com")
    assert !matcher.save
  end
  
end
