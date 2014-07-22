module FlinkerSql
  
  def self.similarities flinker, limit=10
    countries_ids = (Country.ids - [flinker.country_id]).join(",")
    country_id = flinker.country_id || Country.fr.id
    %Q{
      select * from
        (select flinkers.id, count(flinkers.id) from flinkers
        join looks on looks.flinker_id in (
          select flinkers.id from flinkers
          join looks on looks.flinker_id = flinkers.id
          and looks.id in (select resource_id from flinker_likes where flinker_id = #{flinker.id})
        )
        join flinker_likes on flinker_likes.flinker_id = flinkers.id 
          and flinker_likes.resource_id = looks.id 
          and flinker_likes.on = 't'
        and flinkers.id <> #{flinker.id}
        and flinkers.id not in(
          select follow_id from flinker_follows
          where flinker_follows.flinker_id = #{flinker.id}
        )
        group by flinkers.id) fl
      join flinkers on flinkers.id = fl.id
      order by count desc, idx(array[#{country_id}, #{countries_ids}], #{country_id})
      limit 10;
    }
  end
  
  def self.flinker_last_registered_order_by_likes limit=10
    %Q{
      select * from flinkers
      join (select flinker_id, count(*) from flinker_likes group by flinker_id) fl 
      on fl.flinker_id = flinkers.id
      order by created_at::DATE desc, count desc
      limit #{limit};
    }
  end
  
  def self.top_likers_of_publisher_of_look look
    %Q{
      select flinkrs.* from flinkers as flinkrs
      where exists(
        select id from flinker_follows 
        where flinker_follows.follow_id = #{look.flinker_id}
        and flinker_follows.flinker_id = flinkrs.id
      )
      and exists(
        select id from flinker_likes
        where flinker_likes.flinker_id = flinkrs.id
        and flinker_likes.on = 't'
        and flinker_likes.resource_id in (
          select id from looks 
          where flinker_id = #{look.flinker_id}
          and is_published = 't'
        )
      )
    }
  end
  
  def self.top_liked from, max=20, exclusion=[]
    %Q{
      select fl.*, vlikes.count from flinkers fl

       inner join (select flinkers.id as fid, count(*) as count from flinker_likes
        join looks on looks.id = flinker_likes.resource_id
        join flinkers on flinkers.id = looks.flinker_id
        where resource_type = 'look'
        and flinker_likes.updated_at > '#{from}'
        and flinker_likes.on = 't'
        group by flinkers.id
        order by count desc) vlikes
       on vlikes.fid = fl.id 
       
      where fl.is_publisher = 't'
      #{"and fl.id not in (#{exclusion.join(",")})" if exclusion.any? }
      order by vlikes.count desc
      limit #{max};
    }
  end
  
end

