require 'test_helper'

class AlgoliaTest < ActiveSupport::TestCase

  setup do
  end
  
  test "search" do
    skip
    Flinker.reindex!
    raw = Flinker.raw_search("betty")
    puts raw.inspect
    hits = Flinker.search("betty")
    
    assert_equal flinkers(:betty).id, hits.first.id
  end
end