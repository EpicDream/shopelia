module Analytic
  class Publisher
    def initialize publisher, start_date=nil, end_date=nil
      @publisher = publisher
      @start_date = start_date || Rails.configuration.min_date
      @end_date = end_date || Time.now
    end
    
    def self.statistics publisher, weeks=5
      current_year = Date.today.year
      current_week = Date.today.cweek
      
      (0..(weeks - 1)).inject([]) { |stats, week_offset|
        start_date, end_date = [1, 7].map { |day| Date.commercial(current_year, current_week - week_offset, day) }.map(&:to_time)
        stats << Publisher.new(publisher, start_date, end_date).statistics
      }
    end
    
    def statistics
      [:followers, :looks, :likes, :comments, :looks_seen, :blog_clicks, :see_all].inject({}) { |h, key|
        h.merge({ key => send(key)})
      }.merge({ start_date: @start_date.to_i, end_date: @end_date.to_i})
    end
  
    def followers
      FlinkerFollow.where(follow_id: @publisher.id, created_at: @start_date..@end_date).count
    end
  
    def looks
      Look.published.where(flinker_id: @publisher.id, flink_published_at: @start_date..@end_date).count
    end
  
    def likes
      FlinkerLike.likes_for(@publisher).where(updated_at: @start_date..@end_date).count
    end
  
    def comments
      @publisher.comments.where(created_at: @start_date..@end_date).count
    end
  
    def looks_seen
      event(Tracking::SEE_LOOK).count
    end
  
    def blog_clicks
      event(Tracking::CLICK_BLOG).count
    end
  
    def see_all
      event(Tracking::SEE_ALL).count
    end
  
    private
  
    def event name
      Tracking.event(name).for_publisher(@publisher.id).between(@start_date, @end_date)
    end
  end
end