class Statistic
  FROM_REFERENCE = Date.parse("2014/01/01")
  
  def initialize from: FROM_REFERENCE
    @from = to_ruby_date(from) || Date.today
  end
  
  def of_publishers from: @from
    sql = StatisticSql.of_publishers(from)
    ActiveRecord::Base.connection.execute(sql)
  end
  
  private
  
  def to_ruby_date date
    date = Date.parse(date) if date.is_a?(String)
    date
  end
end
