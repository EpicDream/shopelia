class LookImage < Image
  include RankedModel
  belongs_to :look, foreign_key: :resource_id, touch:true

  validates_presence_of :look
  validates :url, :uniqueness => { :scope => :resource_id }

  ranks :display_order, :with_same => :resource_id
end