require 'test_helper'

class MentionActivityTest < ActiveSupport::TestCase
  
  test "find flinkers arobase mentionned in text" do
    text = "Salut @Lilou super ton look, regardez ça @boop et @non_flinker!"
    flinkers = MentionActivity.flinkers_mentionned_in(text)
    
    assert_equal [flinkers(:lilou), flinkers(:boop)], flinkers
  end
  
end