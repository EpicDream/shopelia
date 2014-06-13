class LookSerializer < ActiveModel::Serializer
  attributes :uuid, :name, :url, :published_at, :flinker, :products, :images, :liked, :description
  attributes :updated_at, :flink_published_at, :liked_by_friends, :highlighted_hashtags, :staff_pick
  attributes :comments_count, :likes_count
  
  def name
    object.name.try(:strip)
  end

  def published_at
    object.published_at.to_i
  end
  
  def updated_at
    object.updated_at.to_i
  end
  
  def flink_published_at
    object.flink_published_at.to_i
  end
  
  def comments_count
    object.comments.count
  end
  
  def likes_count
    object.flinker_likes.count
  end

  def flinker
    FlinkerSerializer.new(object.flinker).as_json[:flinker]
  end
  
  def highlighted_hashtags
    object.hashtags.highlighted.map(&:name)
  end

  def products
    object.look_products.map do |lp|
      if lp.product.present? && lp.product.available?
        { code: lp.code.blank? ? "" : I18n.t("flink.products." + lp.code),
          product: ProductSerializer.new(lp.product, scope:scope).as_json[:product] }
      elsif lp.brand.present?
        { code: lp.code.blank? ? "" : I18n.t("flink.products." + lp.code),
          brand: lp.brand }
      end
    end.compact
  end

  def images
    ActiveModel::ArraySerializer.new(object.look_images.order(:display_order)).as_json
  end
  
  def liked_by_friends
    FlinkerLike.liked_by_friends(scope[:flinker], object).map(&:flinker_id)
  end

  def liked
    object.liked_by?(scope[:flinker]) ? 1 : 0
  end

  def include_liked?
    scope.present? && scope[:flinker].present?
  end
  
  def include_liked_by_friends?
    scope && scope[:flinker] && scope[:include_liked_by_friends]
  end
  
  def serializable_hash
    key = ActiveSupport::Cache.expand_cache_key([self.class.to_s.underscore, object.id], 'serializable-hash')
    Rails.cache.fetch(key, expires_in:30.minutes, race_condition_ttl:10) do
      super
    end
  end
end
