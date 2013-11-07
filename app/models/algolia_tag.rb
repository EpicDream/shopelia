class AlgoliaTag < ActiveRecord::Base
  validates :kind, :presence => true
  validates :name, :presence => true

  attr_accessible :count, :kind, :name

end

