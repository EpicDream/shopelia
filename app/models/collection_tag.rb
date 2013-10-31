class CollectionTag < ActiveRecord::Base
  belongs_to :collection
  belongs_to :tag

  validates :collection_id, :presence => true
  validates :tag_id, :presence => true, :uniqueness => { :scope => :collection_id }
  
  attr_accessible :collection_id, :tag_id
end
