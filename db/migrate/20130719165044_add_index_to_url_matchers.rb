class AddIndexToUrlMatchers < ActiveRecord::Migration
  def change
    add_index :url_matchers, :url, :length => 250
    add_index :url_matchers, :canonical, :length => 250
  end
end
