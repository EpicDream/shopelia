class ThemeCover < Image
  belongs_to :theme, foreign_key: :resource_id, touch:true

  validates_presence_of :theme
end