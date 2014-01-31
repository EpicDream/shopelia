class StatisticSql
  
  def self.of_publishers from, to
    %Q{
      select fl.username, fl.name, vlooks.count as looks_count, vfollows.count as follows_count, 
             vlikes.count as likes_count
      from flinkers as fl

       inner join (select looks.flinker_id, count(*) as count from looks 
         where looks.is_published = 't'
         and looks.is_published_updated_at between '#{from}' and '#{to}'
         group by looks.flinker_id order by count desc) vlooks
       on vlooks.flinker_id = fl.id
  
       left outer join (select follow_id, count(*) as count from flinker_follows
         where flinker_follows.updated_at between '#{from}' and '#{to}'
         group by follow_id order by count desc) vfollows
       on vfollows.follow_id = fl.id 
   
       left outer join (select flinkers.id as fid, count(*) as count from flinker_likes
        join looks on looks.id = flinker_likes.resource_id
        join flinkers on flinkers.id = looks.flinker_id
        where resource_type = 'look'
        and flinker_likes.updated_at between '#{from}' and '#{to}'
        group by flinkers.id
        order by count desc) vlikes
       on vlikes.fid = fl.id 
  
      where fl.is_publisher = 't'
      order by vlooks.count desc;
    }
  end
  
end