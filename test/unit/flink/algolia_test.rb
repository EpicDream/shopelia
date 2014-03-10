require 'test_helper'

class AlgoliaTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:betty)
    #Flinker.reindex!
  end
  
  teardown do
  end
  
  test "search" do
    skip
    
    flinkers = Flinker.search("betty")
    assert_equal @flinker.id, flinkers.first.id
    FlinkerLike.create!(flinker_id:flinkers(:betty).id, :resource_type => "look", :resource_id => looks(:agadir).id)
    
  end
  
  test "live update" do
    skip
    
    assert @flinker.update_attributes(email:"Zorro@toto.com")
  
    assert_equal nil, Flinker.search("betty").first
    assert_equal @flinker, Flinker.search("zor").first
  end
  
  test "search filtering with tags" do
    skip
    
    flinkers = Flinker.search("betty", tagFilters:'non-publisher')
    assert_equal nil, flinkers.first
  end
  
  test "creation live update" do
    skip
    
    flinker = Flinker.new(name:"Albator", username:"Corsaire", email:"alb@vega.io")
    flinker.password = "Sylvidres"
    flinker.password_confirmation = "Sylvidres"
    flinker.save!
    
    flinkers = Flinker.search("Alb")
    assert_equal flinker, flinkers.first
  end
end
