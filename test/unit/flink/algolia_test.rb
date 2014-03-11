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
  end
  
  test "live update" do
    skip
    assert @flinker.update_attributes(name:"Zorro", username:"Zorro")
    assert_equal nil, Flinker.search("betty").first
    assert_equal @flinker, Flinker.search("zor").first
  end
  
  test "live update on touch" do #does not work on composed attributes !!
    skip
    Comment.any_instance.stubs(:can_be_posted_on_blog?).returns(false)
    comment = Comment.create(flinker_id:@flinker.id, look_id:looks(:agadir).id, body:"yes")
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
