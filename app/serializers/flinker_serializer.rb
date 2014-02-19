class FlinkerSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :email, :username, :avatar, :country, :staff_pick, :rank, :publisher
  attributes :likes_count, :follows_count, :looks_count, :comments_count, :followed_count

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
    Rails.configuration.image_host + object.avatar.url(:thumb)
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
  
end
