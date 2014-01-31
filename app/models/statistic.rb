class Statistic
  FROM_REFERENCE = Date.parse("2014/01/01")
  
  def initialize from: FROM_REFERENCE, to: Date.today
    @from = from || Date.today
    @to = to || Date.today
    @from, @to = [@from, @to].map { |date| to_ruby_date(date)}
  end
  
  def of_publishers from: @from, to: @to
    sql = StatisticSql.of_publishers(from, to)
    ActiveRecord::Base.connection.execute(sql)
  end
  
  private
  
  def to_ruby_date date
    date = Date.parse(date) if date.is_a?(String)
    date
  end
end
