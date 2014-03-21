class Statistic
  FROM_REFERENCE = Date.parse("2014/01/01")
  
  def initialize from: FROM_REFERENCE
    @from = to_ruby_date(from) || Date.today
  end
  
  def of_publishers from: @from
    sql = StatisticSql.of_publishers(from)
    ActiveRecord::Base.connection.execute(sql)
  end
  
  def self.top_liked_looks_for_day date
    FlinkerLike.where('created_at::DATE >= ? and created_at::DATE < ?', date, date + 1.day)
    .where(resource_type:FlinkerLike::LOOK)
    .group('resource_id')
    .select('resource_id as look_id, count(*)')
    .order('count desc')
    .limit(5)
  end

  def self.top_commented_looks_for_day date
    Comment.where('created_at::DATE >= ? and created_at::DATE < ?', date, date + 1.day)
    .group('look_id')
    .select('look_id, count(*)')
    .order('count desc')
    .limit(5)
  end
  
  private
  
  def to_ruby_date date
    date = Date.parse(date) if date.is_a?(String)
    date
  end
end
