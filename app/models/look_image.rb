class LookImage < Image
  belongs_to :look, foreign_key: :resource_id
  validates_presence_of :look
end