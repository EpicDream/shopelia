class Mapping < ActiveRecord::Base
  audited

  attr_accessible :domain, :mapping
end
