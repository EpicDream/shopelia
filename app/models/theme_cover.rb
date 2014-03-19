class ThemeCover < Image
  belongs_to :theme, foreign_key: :resource_id
end