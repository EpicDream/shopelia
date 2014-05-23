class LookSql
  MIN_DATE = Date.parse("2014-02-01")
  
  def self.popular published_before=Date.today, published_after=MIN_DATE, min_likes=150
    %Q{
      select looks.id, looks.flink_published_at, x.count, x.resource_id from looks
      join (select resource_id, count(*) from flinker_likes group by resource_id having count(*) >= #{min_likes}) x
      on looks.id = x.resource_id

      where looks.is_published = 't'
      and looks.flink_published_at::DATE <= '#{published_before}'
      and looks.flink_published_at::DATE >= '#{published_after}'
  
      order by flink_published_at desc
    }
  end
  
end