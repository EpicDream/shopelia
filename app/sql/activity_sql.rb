module ActivitySql
  def self.counts flinker
    %Q{
      select 
        followings.count as followings, 
        followed.count as followed, 
        likes.count as likes, 
        looks.count as looks, 
        comments.count as comments
      from
       (select count(*) as count from flinker_follows where flinker_id = #{flinker.id}) followings,
       (select count(*) as count from flinker_follows where follow_id = #{flinker.id}) followed,
       (select count(*) as count from flinker_likes where flinker_id = #{flinker.id}) likes,
       (select count(*) as count from looks where flinker_id = #{flinker.id}) looks,
       (select count(*) as count from comments where flinker_id = #{flinker.id}) comments
    }
  end
end

