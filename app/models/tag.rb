class Tag < ActiveRecord::Base
  has_many :collection_tags
  has_many :collections, :through => :collection_tags

  validates :name, :presence => true, :uniqueness => true

  attr_accessible :name

  before_destroy :check_tag_not_used

  private

  def check_tag_not_used
    self.collection_tags.empty?
  end
end
