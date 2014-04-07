class ChangeCertifiedToVerifiedToFlinkers < ActiveRecord::Migration
  def change
    rename_column :flinkers, :certified, :verified
  end
end