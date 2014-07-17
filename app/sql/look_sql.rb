class LookSql
  
  def self.popular published_before=Date.today, published_after=Rails.configuration.min_date, min_likes=150
    %Q{
      select looks.id from looks
      join (select resource_id, count(*) from flinker_likes group by resource_id having count(*) >= #{min_likes}) likes
      on looks.id = likes.resource_id

      where looks.is_published = 't'
      and looks.flink_published_at::DATE <= '#{published_before}'
      and looks.flink_published_at::DATE >= '#{published_after}'
  
      order by flink_published_at desc
    }
  end
  
end