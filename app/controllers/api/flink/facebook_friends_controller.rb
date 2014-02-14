class Api::Flink::FacebookFriendsController < Api::Flink::BaseController
  DEFAULT_PER_PAGE = 40
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
    per_page = params[:per_page] || DEFAULT_PER_PAGE
    res = collection.paginate(page:params[:page], per_page:per_page)
    @has_next = @has_next || res.total_pages > params[:page].to_i
    res
  end
  
  def fetch_facebook_friends
    FacebookFriend.create_or_update_friends(current_flinker)
  end

end