class Revival

  def initialize(flinker, look)
    @flinker = flinker
    @look = look
  end

  def revive?
    true
  end
  
  def after_revive
    #touch revival_at
  end
  
  def revive!
    NewLooksNotificationWorker.perform_in(revive_in, @flinker.id, @look.id) if revive?
  end
  
  def revive_in
    tz = TZInfo::Timezone.get('America/New_York')
    local = tz.utc_to_local(Time.now.utc)
  end
  
  def self.revive! flinkers, look
    flinkers.each { |flinker| Revival.new(flinker, look).revive! }
  end
  
end