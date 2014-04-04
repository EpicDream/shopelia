class AddDevPublicationToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :dev_publication, :boolean, default:false
  end
end