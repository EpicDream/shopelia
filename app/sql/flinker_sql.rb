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
        join flinker_likes on flinker_likes.flinker_id = flinkers.id and resource_id = looks.id
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
  
end

