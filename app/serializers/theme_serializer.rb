class ThemeSerializer < ActiveModel::Serializer
  attributes :id, :title, :subtitle, :position, :cover_height, :country
  attributes :cover_large, :cover_small, :cover_medium
  attributes :looks_count, :flinkers_count
  attributes :looks, :flinkers
  
  def cover_large
    cover_with_format(:large)
  end
  
  def cover_small
    cover_with_format(:pico)
  end
  
  def cover_medium
    cover_with_format(:small)
  end
  
  def looks_count
    object.looks.count
  end
  
  def flinkers_count
    object.flinkers.count
  end
  
  def country
    object.countries.first.iso
  end
  
  def looks
    ActiveModel::ArraySerializer.new(object.looks.includes(:flinker)).as_json
  end
  
  def flinkers
    ActiveModel::ArraySerializer.new(object.flinkers).as_json
  end
  
  def include_country?
    object.countries.first.present?
  end
  
  def include_looks?
    (scope && scope[:full] && object.looks.any?) || uniq_resource?
  end

  def include_flinkers?
    (scope && scope[:full] && object.flinkers.any?) || uniq_resource?
  end
  
  # def serializable_hash
  #   if scope && !scope[:use_cache]
  #     super
  #   else
  #     key = ActiveSupport::Cache.expand_cache_key([self.class.to_s.underscore, object.id], 'serilizable-hash')
  #     Rails.cache.fetch(key, expires_in:30.minutes, race_condition_ttl:10) do
  #       super
  #     end
  #   end
  # end
  
  private
  
  def uniq_resource?
    looks.count + flinkers.count == 1
  end
  
  def cover_with_format format
    Rails.configuration.image_host + object.theme_cover.picture.url(format, timestamp:true)
  end
  
end