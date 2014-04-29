module FlinkerSql
  def self.similarities flinker
    countries_ids = (Country.ids - [flinker.country_id]).join(",")
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
      order by count desc, idx(array[#{flinker.country_id}, #{countries_ids}], #{flinker.country_id});
    }
  end
end

