class FlinkerSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :email, :username, :avatar, :country, :staff_pick, :rank, :publisher, :verified
  attributes :likes_count, :follows_count, :looks_count, :comments_count, :followed_count, :liked_count
  attributes :cover_small, :cover_large, :cover_medium
  
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
  
  def cover_small
    cover_with_format(:pico)
  end

  def cover_large
    cover_with_format(:large)
  end
  
  def cover_medium
    cover_with_format(:small)
  end
    
  def include_liked_count?
    object.is_publisher?
  end
  
  def serializable_hash
    key = ActiveSupport::Cache.expand_cache_key([self.class.to_s.underscore, object.id], 'serilizable-hash')
    Rails.cache.fetch(key, expires_in:30.minutes, race_condition_ttl:10) do
      super
    end
  end
  
  private
  
  def cover_with_format format
    return unless image = object.cover_image
    Rails.configuration.image_host + image.picture.url(format)
  end
  
end
