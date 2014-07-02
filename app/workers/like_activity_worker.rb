class LikeActivityWorker
  include Sidekiq::Worker
  
  def perform flinker_like_id
    flinker_like = FlinkerLike.find(flinker_like_id)
    flinker = flinker_like.flinker
    flinker.followers.each do |friend|
      LikeActivity.create(flinker_id:flinker.id, target_id:friend.id, resource_id:flinker_like.id)
    end
  end
end
