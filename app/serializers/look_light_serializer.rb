class LookLightSerializer < ActiveModel::Serializer
  attributes :uuid, :liked_by_friends, :hashtags, :comments_count, :likes_count
  
  def liked_by_friends
    FlinkerLike.liked_by_friends(scope[:flinker], object).map(&:flinker_id)
  end
  
  def hashtags
    object.hashtags.highlighted.map(&:name)
  end
  
  def comments_count
    object.comments.count
  end
  
  def likes_count
    object.flinker_likes.count
  end
  
  def include_liked_by_friends?
    scope && scope[:flinker]
  end
  
end
