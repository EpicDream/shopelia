class Api::Flink::TwitterFriendsController < Api::Flink::BaseController
  before_filter :fetch_twitter_friends
  
  def index
    @user = TwitterUser.find_by_flinker_id(current_flinker)
    render json: {}, status: :not_found and return unless @user
    render json: { flinkers:serialize(flinkers), has_next: @has_next }
  end
  
  private
  
  def flinkers
    users = paged TwitterUser.friendships_of(@user), per_page: 40
    users.map(&:flinker)
  end
  
  def fetch_twitter_friends
    key = ActiveSupport::Cache.expand_cache_key(["twitter_friends", current_flinker.id])
    Rails.cache.fetch(key, expires_in: 1.hour) { @user.friends(refresh: true) if @user }
  end
  
end