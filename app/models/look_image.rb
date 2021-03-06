class LookImage < Image
  belongs_to :look, foreign_key: :resource_id, touch:true

  validates_presence_of :look
  validates :url, :uniqueness => { :scope => :resource_id }

end