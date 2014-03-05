require 'test_helper'

class AlgoliaTest < ActiveSupport::TestCase

  # setup do
  #   WebMock.disable!
  #   @flinker = flinkers(:betty)
  #   Flinker.reindex!
  # end
  # 
  # teardown do
  #   WebMock.enable!
  # end
  # 
  # test "search" do
  #   flinkers = Flinker.search("betty")
  #   assert_equal @flinker.id, flinkers.first.id
  # end
  # 
  # test "live update" do
  #   assert @flinker.update_attributes(username:"Zorro", name:"Zorro")
  # 
  #   assert_equal nil, Flinker.search("betty").first
  #   assert_equal @flinker, Flinker.search("zor").first
  # end
  # 
  # test "search filtering with tags" do
  #   flinkers = Flinker.search("betty", tagFilters:'non-publisher')
  #   assert_equal nil, flinkers.first
  # end
  # 
  # test "creation live update" do
  #   flinker = Flinker.new(name:"Albator", username:"Corsaire", email:"alb@vega.io")
  #   flinker.password = "Sylvidres"
  #   flinker.password_confirmation = "Sylvidres"
  #   flinker.save!
  #   
  #   flinkers = Flinker.search("Alb")
  #   assert_equal flinker, flinkers.first
  # end
end
