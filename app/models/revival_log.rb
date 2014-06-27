class RevivalLog < ActiveRecord::Base
  attr_accessible :count
  
  def self.increment day
    log = RevivalLog.where('created_at::DATE = ?', day).first || create(count:0)
    update_counters log.id, count: 1
  end
end