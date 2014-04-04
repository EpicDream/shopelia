class FlinkerSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :email, :username, :avatar, :country, :staff_pick, :rank, :publisher
  attributes :likes_count, :follows_count, :looks_count, :comments_count, :followed_count
  attributes :liked_count, :cover_image
  
  def publisher
    object.is_publisher? ? 1 : 0
  end

  def staff_pick
    object.staff_pick ? 1 : 0
  end

  def name
    object.name.try(:strip)
  end

  def country
    object.country.try(:iso)
  end

  def avatar
    Rails.configuration.avatar_host + object.avatar.url(:thumb, timestamp:true)
  end

  def rank
    object.display_order
  end
  
  def likes_count
    object.activities_counts["likes"]
  end
  
  def follows_count
    object.activities_counts["followings"]
  end
  
  def looks_count
    object.activities_counts["looks"]
  end
  
  def comments_count
    object.activities_counts["comments"]
  end
  
  def followed_count
    object.activities_counts["followed"]
  end
  
  def liked_count
    FlinkerLike.liked_for(object).count
  end
  
  def cover_image
    image = object.cover_image
    { small: image.picture.url(:pico), large: image.picture.url(:large) }
  end
  
  def include_liked_count?
    object.is_publisher?
  end
  
  def include_cover_image?
    object.cover_image.present?
  end
  
end
