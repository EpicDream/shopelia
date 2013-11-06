class AlgoliaTag < ActiveRecord::Base
  validates :kind, :presence => true
  validates :name, :presence => true

  attr_accessible :count, :kind, :name

  def self.build_from_redis
    redis = Redis.new
    AlgoliaTag.transaction do 
      AlgoliaTag.destroy_all
      redis.hkeys("algolia_tags").each do |key|
        kind, name = key.split(/\:/)
        count = redis.hget(key).to_i
        AlgoliaTag.create(name:name, kind:kind, count:count)
      end
    end
  end
end