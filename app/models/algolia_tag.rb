class AlgoliaTag < ActiveRecord::Base
  validates :kind, :presence => true
  validates :name, :presence => true

  attr_accessible :count, :kind, :name

  def self.build_from_redis
    redis = Redis.new
    AlgoliaTag.delete_all
    redis.hkeys("algolia_tags").each do |key|
      kind, name = key.split(/\:/)
      count = redis.hget("algolia_tags", key).to_i
      next if count < 10
      name = name.squeeze
      AlgoliaTag.create(name:name, kind:kind, count:count) if name.length < 80
    end
  end
end
