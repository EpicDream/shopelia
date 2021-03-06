class Statistic
  FROM_REFERENCE = Date.parse("2014/01/01")
  
  def initialize from: FROM_REFERENCE
    @from = to_ruby_date(from) || Date.today
  end
  
  def of_publishers from: @from
    sql = StatisticSql.of_publishers(from)
    ActiveRecord::Base.connection.execute(sql)
  end
  
  def self.top_liked_looks_for_period from, to=nil, limit=5
    to ||= from + 1.day
    FlinkerLike.where('created_at::DATE >= ? and created_at::DATE < ?', from, to)
    .where(resource_type:FlinkerLike::LOOK)
    .group('resource_id')
    .select('resource_id as look_id, count(*)')
    .order('count desc')
    .limit(limit)
  end

  def self.top_commented_looks_for_day date
    Comment.where('created_at::DATE >= ? and created_at::DATE < ?', date, date + 1.day)
    .group('look_id')
    .select('look_id, count(*)')
    .order('count desc')
    .limit(5)
  end
  
  def self.top_active_flinkers from, to=nil, limit=20
    to ||= from + 1.day
    Flinker.joins("
      join (select flinker_id, count(*) from flinker_likes
      where created_at::DATE >= '#{from}' and created_at::DATE <= '#{to}'
      group by flinker_id) likes on likes.flinker_id = flinkers.id")
    .order('likes.count desc')
    .select('flinkers.*, likes.count as count')
    .limit(limit)  
  end
  
  private
  
  def to_ruby_date date
    date = Date.parse(date) if date.is_a?(String)
    date
  end
end
