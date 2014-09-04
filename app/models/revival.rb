class Revival
  REVIVE_AT = 10 #10:00am local
  LAST_SESSION_MIN = 24.hours
  LAST_REVIVE_MIN = 1.week
  
  def initialize(flinker, look)
    @flinker = flinker
    @look = look
  end

  def revive?
    @flinker.timezone &&
    (Time.now - @flinker.last_session_open_at) > LAST_SESSION_MIN &&
    (Time.now - @flinker.last_revival_at) > LAST_REVIVE_MIN
  end
  
  def after_revive
    @flinker.touch(:last_revival_at)
  end
  
  def revive!
    @flinker.touch(:last_session_open_at) unless @flinker.last_session_open_at
    return unless revive?
    RevivalLog.increment(Date.today)
    NewLooksNotificationWorker.perform_in(revive_in, @flinker.id, @look.id)
    after_revive
  end
  
  def revive_in
    tz = ActiveSupport::TimeZone.new(@flinker.timezone)
    time = tz.utc_to_local(Time.now.utc)
    time2 =  time.hour >= REVIVE_AT ? time + (60 * 60 * 24) : time
    target = tz.utc_to_local(tz.local(time2.year, time2.month, time2.day, REVIVE_AT).utc)
    target - time
  end
  
  def self.revive! flinkers, look
    flinkers = Flinker.top_likers_of_publisher_of_look(look)
    
    flinkers.each { |flinker| 
      begin
        Revival.new(flinker, look).revive! 
      rescue => e
        Rails.logger.error("[REVIVAL] #{e.inspect} #{e.backtrace.join("\n")}")
      end
    }
  end
  
end