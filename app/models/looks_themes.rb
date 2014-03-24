class LooksThemes < ActiveRecord::Base
  validates :look_id, uniqueness: { :scope => :theme_id}
end