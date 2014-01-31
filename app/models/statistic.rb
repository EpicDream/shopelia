require 'statistic_sql'

class Statistic

  def initialize
  end
  
  def of_publishers_between from, to
    sql = StatisticSql.of_publishers(from, to)
    ActiveRecord::Base.connection.execute(sql)
  end
  
end