class BlogSql
  def self.without_look_published_since interval
    %Q{
      select distinct on(blogs.url) blogs.*, flink_published_at from blogs
      join looks on looks.flinker_id=blogs.flinker_id
      where looks.is_published = 't'
      and not exists(
        select id from looks
        where looks.flinker_id=blogs.flinker_id
        and looks.flink_published_at::DATE >= '#{Time.now - interval}'
      )
      order by blogs.url asc, flink_published_at desc;
    }
  end
end