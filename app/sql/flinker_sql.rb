module FlinkerSql
  def self.similarities flinker
    %Q{
      select flinkers.id, count(flinkers.id) from flinkers
      join looks on looks.flinker_id in (
        select flinkers.id from flinkers
        join looks on looks.flinker_id = flinkers.id
        and looks.id in (select resource_id from flinker_likes where flinker_id = #{flinker.id})
      )
      join flinker_likes on flinker_likes.flinker_id = flinkers.id and resource_id = looks.id
      and flinkers.id <> #{flinker.id}
      group by flinkers.id
      order by count desc
      limit 10;
    }
  end
end

