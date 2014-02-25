class SetDefaultCountryToBlogs < ActiveRecord::Migration
  def change
    change_column_default :blogs, :country, "FR"
  end
end