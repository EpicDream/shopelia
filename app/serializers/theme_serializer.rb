class ThemeSerializer < ActiveModel::Serializer
  MIN_BUILD_FOR_NEW_FONTS = 36 # >=
  
  attributes :id, :title, :subtitle, :position, :cover_height, :country
  attributes :cover_large, :cover_small, :cover_medium
  attributes :looks_count, :flinkers_count
  attributes :looks, :flinkers
  
  def title
    object.title_for_ios(scope[:lang], scope[:build] < MIN_BUILD_FOR_NEW_FONTS)
  end
  
  def subtitle
    object.subtitle_for_ios(scope[:lang])
  end
  
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
    looks = object.looks.includes(:flinker).includes(:post).order('posts.published_at desc')
    ActiveModel::ArraySerializer.new(looks).as_json
  end
  
  def flinkers
    ActiveModel::ArraySerializer.new(object.flinkers).as_json
  end
  
  def include_country?
    object.countries.first.present?
  end
  
  def include_looks?
    (scope[:full] && object.looks.any?) || uniq_resource?
  end

  def include_flinkers?
    (scope[:full] && object.flinkers.any?) || uniq_resource?
  end
  
  private
  
  def uniq_resource?
    looks.count + flinkers.count == 1
  end
  
  def cover_with_format format
    Rails.configuration.image_host + object.theme_cover.picture.url(format, timestamp:true)
  end
  
end