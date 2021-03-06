class LookLightSerializer < ActiveModel::Serializer
  attributes :uuid, :liked_by_friends, :highlighted_hashtags, :comments_count, :likes_count
  
  def liked_by_friends
    FlinkerLike.liked_by_friends(scope[:flinker], object).map(&:flinker_id)
  end
  
  def highlighted_hashtags
    object.highlighted_hashtags.map(&:name)
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
