class WebService::FlinkerSerializer < ActiveModel::Serializer
  self.root = false
  attributes :uuid, :username
  attributes :counters

  def counters
    counts = object.activities_counts
    { looks:counts["looks"], followers:counts["followed"], likes:FlinkerLike.liked_for(object).count }
  end

  def serializable_hash
    Rails.cache.fetch([:ws, :flinker, :serializer, object.uuid], race_condition_ttl:10, expires_in:30.minutes) do
      super
    end
  end

end
