require 'test_helper'

class ShareActivityTest < ActiveSupport::TestCase
  
  setup do
    @look = looks(:agadir)
    @flinker = flinkers(:lilou)
    follow(@flinker, flinkers(:fanny))
    follow(@flinker, flinkers(:boop))
  end
  
  test "create share activity for followers of flinker sharing via facebook or twitter" do
    assert_difference('ShareActivity.count', 2) do
      LookSharing.on("twitter").for(look_id:@look.id, flinker_id:@flinker.id)
    end
  end

end