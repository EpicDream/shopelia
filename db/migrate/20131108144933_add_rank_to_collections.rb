class AddRankToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :rank, :integer
  end
end
