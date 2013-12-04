class AddNameAvatarAndCountryToBlogs < ActiveRecord::Migration
  def change
    add_column :blogs, :avatar_url, :string
    add_column :blogs, :country, :string
    add_column :blogs, :scraped, :boolean, default:true
  end
end