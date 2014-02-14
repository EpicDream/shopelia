class Api::Flink::FacebookFriendsController < Api::Flink::BaseController
  before_filter :fetch_facebook_friends, if: -> { FacebookFriend.of_flinker(current_flinker).limit(1).count.zero? }
  
  def index
    render json: { flinkers:flinkers, has_next:@has_next }
  end
  
  private
  
  def flinkers
    flink = paged(FacebookFriend.of_flinker(current_flinker).flinkers).map(&:friend)
    facebook = paged FacebookFriend.of_flinker(current_flinker).not_flinkers
    { facebook:ActiveModel::ArraySerializer.new(facebook), flink:ActiveModel::ArraySerializer.new(flink) }
  end
  
  def paged collection
    res = collection.paginate(pagination(40))
    @has_next = @has_next || res.total_pages > params[:page].to_i
    res
  end
  
  def fetch_facebook_friends
    FacebookFriend.create_or_update_friends(current_flinker)
  end
  
end