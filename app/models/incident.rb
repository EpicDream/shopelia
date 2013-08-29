class Incident < ActiveRecord::Base
  CRITICAL = 0
  IMPORTANT = 1
  INFORMATIVE = 2

  validates :issue, :presence => true
  validates :description, :presence => true
  validates :severity, :presence => true, :inclusion => { :in => [ CRITICAL, IMPORTANT, INFORMATIVE ] }

  attr_accessible :description, :issue, :severity, :resource_type, :resource_id
end
