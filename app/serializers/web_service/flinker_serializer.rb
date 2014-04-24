class WebService::FlinkerSerializer < ActiveModel::Serializer
  self.root = false
  attributes :uuid, :username
  attributes :counters

  def counters
    counts = object.activities_counts
    { looks:counts["looks"], followers:counts["followed"], likes:FlinkerLike.liked_for(object).count }
  end

  def serializable_hash
    Rails.cache.fetch(object, race_condition_ttl:10) do
      super
    end
  end

end
