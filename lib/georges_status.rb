# -*- encoding : utf-8 -*-
class GeorgesStatus

  AVAILABLE = "available"
  SLEEPING = "sleeping"
  HOLIDAY = "holiday"
  OVERVORKED = "overworked"

  STATUSES = [AVAILABLE, SLEEPING, HOLIDAY, OVERVORKED]

  def self.get
    Redis.new.hget("georges", "status") || AVAILABLE
  end

  def self.message
    I18n.t("georges.#{self.get}")
  end

  def self.set status
    Redis.new.hset("georges", "status", status)
  end
end