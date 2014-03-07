class Api::Flink::FacebookFriendsController < Api::Flink::BaseController
  before_filter :fetch_facebook_friends
  
  def index
    render json: { flinkers:flinkers, has_next:@has_next }
  end
  
  private
  
  def flinkers
    flinks = paged FacebookFriend.of_flinker(current_flinker).flinkers, per_page:40
    facebooks = paged FacebookFriend.of_flinker(current_flinker).not_flinkers, per_page:40
    { facebook: serialize(facebooks), flink: serialize(flinks.map(&:friend)) }
  end
  
  def fetch_facebook_friends
    FacebookFriend.create_or_update_friends(current_flinker)
  end
  
end