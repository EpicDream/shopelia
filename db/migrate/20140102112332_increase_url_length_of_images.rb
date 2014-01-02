class IncreaseUrlLengthOfImages < ActiveRecord::Migration
  def up
    change_column :images, :url, :string, limit:1024
  end

  def down
    change_column :images, :url, :string
  end
end