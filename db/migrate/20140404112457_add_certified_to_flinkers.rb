class AddCertifiedToFlinkers < ActiveRecord::Migration
  def change
    add_column :flinkers, :certified, :boolean, default:false
  end
end